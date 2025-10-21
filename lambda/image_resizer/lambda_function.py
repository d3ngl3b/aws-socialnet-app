import boto3
import os
from urllib.parse import unquote_plus
from PIL import Image

s3_client = boto3.client('s3')

# Maximum dimensions for resizing
MAX_WIDTH = 800
MAX_HEIGHT = 800

def resize_image(image_path, resized_path):
    """
    Resize the image to fit within MAX_WIDTH x MAX_HEIGHT while maintaining aspect ratio.
    """
    with Image.open(image_path) as image:
        image.thumbnail((MAX_WIDTH, MAX_HEIGHT))
        image.save(resized_path)
        # Return correct content type for upload
        return Image.MIME.get(image.format, 'image/jpeg')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])

        # Skip already processed files (optional, e.g., avoid recursive triggers)
        if key.startswith("resized-temp/"):  # or any temporary marker if needed
            print(f"Skipping already processed file: {key}")
            continue

        filename = os.path.basename(key)
        folder = os.path.dirname(key)

        download_path = f"/tmp/{filename}"
        resized_path = f"/tmp/resized-{filename}"

        # Download original image
        s3_client.download_file(bucket, key, download_path)
        print(f"Downloaded {key} from bucket {bucket}")

        # Resize image
        content_type = resize_image(download_path, resized_path)
        print(f"Resized image saved to {resized_path}")

        # Overwrite original image with resized one
        s3_client.upload_file(
            resized_path,
            bucket,
            key,  # same key as original
            ExtraArgs={'ContentType': content_type}
        )
        print(f"Overwritten original image with resized version: {bucket}/{key}")

        # Cleanup Lambda temp files
        for path in [download_path, resized_path]:
            try:
                os.remove(path)
            except Exception as e:
                print(f"Cleanup error: {e}")
