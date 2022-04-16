[![Rapidfort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)](https://rapidfort.com) 

# Contributing Guidelines

Contributions are welcome via GitHub Pull Requests. This document outlines the process to help get your contribution accepted.

Any type of contribution is welcome; from new features, bug fixes, [tests](#testing), documentation improvements or even [adding images to the repository](#adding-a-new-image-to-the-repository) (if it's viable once evaluated the feasibility).

## How to Contribute

1. Fork this repository, develop, and test your changes.
2. Submit a pull request.

***NOTE***: To make the Pull Requests' (PRs) testing and merging process easier, please submit changes to multiple images in separate PRs.

### Technical Requirements

When submitting a PR make sure that it:
- Must pass CI jobs for linting and test the changes on top of different k8s platforms. (Automatically done by the Plenum CI/CD pipeline).

#### Sign Your Work

The sign-off is a simple line at the end of the explanation for a commit. All commits needs to be signed. Your signature certifies that you wrote the patch or otherwise have the right to contribute the material. The rules are pretty simple, you only need to certify the guidelines from [developercertificate.org](https://developercertificate.org/).

Then you just add a line to every git commit message:

    Signed-off-by: John Doe <john.doe@example.com>

Use your real name (sorry, no pseudonyms or anonymous contributions.)

If you set your `user.name` and `user.email` git configs, you can sign your commit automatically with `git commit -s`.

Note: If your git config information is set properly then viewing the `git log` information for your commit will look something like this:

```
Author: John Doe <john.doe@example.com>
Date:   Thu Feb 2 11:41:15 2018 -0800

    Update README

    Signed-off-by: John Doe <john.doe@example.com>
```

Notice the `Author` and `Signed-off-by` lines match. If they don't your PR will be rejected by the automated DCO check.

### Documentation Requirements

- An image must include `README.md`. 
- The title of the PR starts with image name (e.g. `[image/provider]`)

### PR Approval and Release Process

1. Changes are automatically linted and tested using Github actions.
1. Changes are manually reviewed by Plenum team members. 
1. When the PR passes all tests, the PR is merged by the reviewer(s) in the GitHub `master` branch.
1. Then our CI/CD system is going to push the image to the Rapidfort Dockerhub registry.

### Testing 

1. Determine the types of tests you will need based on the image you are testing.
1. Ensure tests exercise all the workflows to ensure hardened image dont break in production.

### Adding a new image to the repository

There are two major technical requirements to add a new image to our catalog:
- Follow the same structure/patterns that the rest of the Plenum images (you can find a basic scaffolding in the [`template` directory](https://github.com/rapidfort/plenum/tree/master/template)).
- Use an [OSI approved license](https://opensource.org/licenses) for all the software.

Please, note we will need to check internally and evaluate the feasibility of adding the new solution to the catalog. Due to limited resources this step could take some time.