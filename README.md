# Trivy Pipe

> This is a maintained fork of the abandoned original [Bitbucket Pipeline](https://bitbucket.org/product/features/pipelines/) for [Trivy](https://github.com/aquasecurity/trivy)

## Usage

### Workflow

```yaml
image: 
    name: atlassian/default-image:4

pipelines:
  default:
    - step:
        service:
          docker
        script:
        - pipe: docker://wollomatic/trivy-pipe:latest
          variables:
            imageRef: 'docker.io/my-organization/my-app:${{ github.sha }}'
            format: 'table'
            exitCode: '1'
            ignoreUnfixed: true
            pkgTypes: 'os,library'
            severity: 'CRITICAL,HIGH'
            disableTelemetry: 'true'
            skipVersionCheck: 'true'
#            dbRepository: "public.ecr.aws/aquasecurity/trivy-db:2" # uncomment this if needed
```

### Using Trivy to scan your Git repo
It's also possible to scan your git repos with Trivy's built-in repo scan. This can be handy if you want to run Trivy as a build time check on each PR that gets opened in your repo. This helps you identify potential vulnerablites that might get introduced with each PR.

```yaml
image: 
    name: atlassian/default-image:4

pipelines:
  default:
    - step:
        service:
          docker
        script:
          - pipe: docker://wollomatic/trivy-pipe:latest
            variables:
              scanType: 'fs'
              ignoreUnfixed: true
              format: 'template'
              template: '@/contrib/sarif.tpl'
              output: 'trivy-results.sarif'
              severity: 'CRITICAL'
              disableTelemetry: 'true'
              skipVersionCheck: 'true'
```

### Using Trivy to scan Infrastucture as Code
It's also possible to scan your IaC repos with Trivy's built-in repo scan. This can be handy if you want to run Trivy as a build time check on each PR that gets opened in your repo. This helps you identify potential vulnerablites that might get introduced with each PR.

```yaml
image:
  name: atlassian/default-image:4

pipelines:
  default:
    - step:
        services:
          - docker
        script:
          - pipe: docker://wollomatic/trivy-pipe:latest
            variables:
              scanType: "config"
              hideProgress: "false"
              format: "table"
              exitCode: 1
              ignoreUnfixed: "true"
              severity: "CRITICAL,HIGH"
              disableTelemetry: 'true'
              skipVersionCheck: 'true'
```

### Using Trivy to scan your private registry
It's also possible to scan your private registry with Trivy's built-in image scan. All you have to do is set ENV vars.

#### Docker Hub registry
Docker Hub needs `TRIVY_USERNAME` and `TRIVY_PASSWORD`.
You don't need to set ENV vars when downloading from a public repository.
```yaml
image:
  name: atlassian/default-image:4

pipelines:
  default:
    - step:
        services:
          - docker
        script:
          - pipe: docker://wollomatic/trivy-pipe:latest
            variables:
              imageRef: 'docker.io/my-organization/my-app:${{ github.sha }}'
              format: 'template'
              template: '@/contrib/sarif.tpl'
              output: 'trivy-results.sarif'
              TRIVY_USERNAME: Username
              TRIVY_PASSWORD: Password  
              disableTelemetry: 'true'
              skipVersionCheck: 'true'
```

#### AWS ECR (Elastic Container Registry)
Trivy uses AWS SDK. You don't need to install `aws` CLI tool.
You can use [AWS CLI's ENV Vars][env-var].

[env-var]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
```yaml
image: 
    name: atlassian/default-image:4

pipelines:
  default:
    - step:
        services:
          - docker
        script:
          - pipe: docker://wollomatic/trivy-pipe:latest
            variables:
              imageRef: 'aws_account_id.dkr.ecr.region.amazonaws.com/imageName:${{ github.sha }}'
              format: 'template'
              template: '@/contrib/sarif.tpl'
              output: 'trivy-results.sarif'
              AWS_ACCESS_KEY_ID: key_id
              AWS_SECRET_ACCESS_KEY: access_key
              AWS_DEFAULT_REGION: us-west-2
              disableTelemetry: 'true'
              skipVersionCheck: 'true'
```

#### GCR (Google Container Registry)
Trivy uses Google Cloud SDK. You don't need to install `gcloud` command.

If you want to use target project's repository, you can set it via `GOOGLE_APPLICATION_CREDENTIAL`.
```yaml
image: 
    name: atlassian/default-image:4

pipelines:
  default:
    - step:
        services:
          - docker
        script:
          - pipe: docker://wollomatic/trivy-pipe:latest
            variables:
              imageRef: 'docker.io/my-organization/my-app:${{ github.sha }}'
              format: 'template'
              template: '@/contrib/sarif.tpl'
              output: 'trivy-results.sarif'
              GOOGLE_APPLICATION_CREDENTIAL: /path/to/credential.json
              disableTelemetry: 'true'
              skipVersionCheck: 'true'
```

#### Self-Hosted
BasicAuth server needs `TRIVY_USERNAME` and `TRIVY_PASSWORD`.
if you want to use 80 port, use NonSSL `TRIVY_NON_SSL=true`
```yaml
image: 
    name: atlassian/default-image:4

pipelines:
  default:
    - step:
        services:
          - docker
        script:
          - pipe: docker://wollomatic/trivy-pipe:latest
            variables:
              imageRef: 'docker.io/my-organization/my-app:${{ github.sha }}'
              format: 'template'
              template: '@/contrib/sarif.tpl'
              output: 'trivy-results.sarif'
              TRIVY_USERNAME: Username
              TRIVY_PASSWORD: Password   
              disableTelemetry: 'true'
              skipVersionCheck: 'true'
```

## Customizing

### inputs

Following inputs can be used as `step.with` keys:

| Name                | Type     | Default                            | Description                                                                            |
|---------------------|----------|------------------------------------|----------------------------------------------------------------------------------------|
| `scanType`          | String   | `image`                            | Scan type, e.g. `image` or `fs`                                                        |
| `input`             | String   |                                    | Tar reference, e.g. `alpine-latest.tar`                                                |
| `imageRef`          | String   |                                    | Image reference, e.g. `alpine:3.10.2`                                                  |
| `scanRef`           | String   |                                    | Scan reference, e.g. `.`                                                               |
| `format`            | String   | `table`                            | Output format (`table`, `json`, `template`)                                            |
| `template`          | String   |                                    | Output template (`@/contrib/sarif.tpl`, `@/contrib/gitlab.tpl`, `@/contrib/junit.tpl`) |
| `output`            | String   |                                    | Save results to a file                                                                 |
| `exitCode`          | String   | `0`                                | Exit code when specified vulnerabilities are found                                     |
| `ignoreUnfixed`     | Boolean  | false                              | Ignore unpatched/unfixed vulnerabilities                                               |
| `vulnType`          | String   |                                    | Vulnerability types (os,library) (deprecated, use pkgTypes instead)                    |
| `pkgTypes`          | String   | `os,library`                       | list of package types (os,library) (os,library)                                        |
| `severity`          | String   | `UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL` | Severities of vulnerabilities to scanned for and displayed                             |
| `skipDirs`          | String   |                                    | Comma separated list of directories where traversal is skipped                         |
| `cacheDir`          | String   |                                    | Cache directory                                                                        |
| `timeout`           | String   | `2m0s`                             | Scan timeout duration                                                                  |
| `ignorePolicy`      | String   |                                    | Filter vulnerabilities with OPA rego language                                          |
| `hideProgress`      | Boolean  | false                              | suppress progress bar                                                                  |
| `dbRepository`      | String   |                                    | vulnerability DB repository                                                            |
| `javaDBRepository`  | String   |                                    | vulnerability Java index DB repository                                                 |
| `disableTelemetry`  | Boolean  | false                              | disable telemetry introduced in Trivy 0.63.0                                           |
| `skipVersionCheck`  | Boolean  | false                              | disable version check introduced in Trivy 0.63.0                                       |

[license]: https://github.com/aquasecurity/trivy-pipe/blob/master/LICENSE
[license-img]: https://img.shields.io/github/license/aquasecurity/trivy-pipe
