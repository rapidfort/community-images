[![Rapidfort](/contrib/github_logo.png)](https://rapidfort.com)

# Trouble Shooting Guide

## Background:
"RapidFort Community Images" is an open-source project to continuously optimize and harden popular Docker images. We pick up a source image ("upstream image"), add coverage scripts, and use RapidFort to optimize and harden the image. A hardened image is automatically created every time a new image is pushed to Docker Hub.


Optimized images are significantly smaller and carry fewer vulnerabilities while providing the complete functionality of the original image.

You can contribute to this project by adding new images, improving coverage scripts, and adding regression and benchmark tests.

![Demo](contrib/workflow.png)

The community images project relies on the upstream source images to work correctly. Broadly, the issues will fall into the following categories:


1. ### The coverage script does not exercise a feature used in production (Coverage missing).
    > Remediation: We need to enhance coverage scripts. Please report an issue and provide PR if possible.

1. ### Incorrect usage of the upstream source image (User error).
    > Remediation: Please file a report and update the documentation for the image.

1. ### Upstream source image has introduced a defect (Source image error).
    > Remediation: Please file a report on the source project. For eg: Bitnami Postgres image.

1. ### RapidFort hardened image is introducing a defect (RF error).
    > Remediation: Please report an issue, and we will work with our core engineering team to investigate and fix this issue.
