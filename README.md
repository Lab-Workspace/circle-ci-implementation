# Circle CI Implementation
## Introduction
The main purpose of this repository is to have a simple explanation on how to deploy a **CircleCI** pipeline and how to configure **Github** to add security (block push on main branch without PR, block merge on main branch if CI pipeline broken, etc).

## Enable CircleCI on a Github Repository

CircleCI can be added on any kind of repo, free Github subscription is sufficient.
It's not the case of branch security configuration on Github (we will the that on the next section).

1. Go on [CircleCI website](https://circleci.com/vcs-authorize/?return-to=https%3A%2F%2Fapp.circleci.com%2Fprojects%2F) and click on `Log In with Github`.
2. Select the organization you want CircleCI to give access to. If it's on a personal repo related to your account (not an organization) click on your login.
3. CircleCI will show you a list of all repos related to your previous selection. Click on the `Set Up Project` button next to the repo which you want enable CircleCI on to start using it.
4. At this stage, you have 3 possibilities. Choose one and click on the `Set Up Project` button:
    * **Fastest**: this one is adapted if you already have a CircleCI configuration in your repository.
    * **Faster**: it will create a new branch that containes a helloworld CircleCI config file. It will create a branch called `circleci-project-setup` (We will chose this option for the next steps).
    * **Fast**: will do the same as *Faster* but with your own config file. Useful if you already have one.
5. Merge create a Pull Request from the branch pushed by CircleCI.
6. Configure Github Checks which is used to display CircleCI informations on PR:
    * Go back on [CircleCI website](https://circleci.com/vcs-authorize/?return-to=https%3A%2F%2Fapp.circleci.com%2Fprojects%2F)
    * Click on `Organization Settings` on the left side-bar.
    * Click on `VCS` and `Manage Github Checks`.
    * You will be redirect to Github. Give all persmissions required by CircleCI to work.

> ### **Warning**:
> Sometimes, CircleCI has issue with creating a SSH Key for deployment which is mandatory to run jobs correctly.
> If you have an issue like "**Permission denied (publickey)**":
>   1. Go on [CircleCI website](https://circleci.com/vcs-authorize/?return-to=https%3A%2F%2Fapp.circleci.com%2Fprojects%2F)
>   2. Click on your repo/project.
>   3. Click on `Project Settings` on the top right.
>   4. Click on `SSH Keys` on the left side-bar.
>   5. Click on the cross to remove the current **Deploy Key**. It will remove it.
>   6. Create a new one by clicking on `Add Deploy Key` button.
>
> The problem should be solved now.

To be able to connect on the machine used to run the job you are targeting, you need to go on this specific job, click on `Rerun` in the top right side and `Rerun Job with SSH`. Into the **Enable SSH**, you will find an ssh command to connect on the machine.

> ### **Warning**:
> If you try to use it in a different environment, it's possible that you don't have associated your ssh key to your Github account. This step is mandatory if you need to get an access on the VM, otherwise you won't have the permission to get an access into it. To add a new SSH key associated to your github account, follow the steps described below: 
>   1. Go on [Github website](https://github.com/)
>   2. Click on your profile in the top right corner and `Settings`.
>   3. Click on `SSH and GPG keys` on the left side-bar.
>   4. Click on `New SSH key` and copy and paste your public key + give it a title. The SSH key need to be an **ed25519**. If it's not the case, create on with the following command:
> ```bash
> ssh-keygen -t ed25519 -C your_email@example.com
> ```
> Try again to connect on with the ssh command, it should work.

## Configure repository to block merging with Github Branch Security feature
Github Security Branch allow you to add some conditions to meet on a specific repository to be able to merge a PR into another branch.
In our case, we want to add conditions listed below on the main branch:
* Block if the branch is not up-to-date compared to main branch.
* PR require at least one approval before merging.
* Require that all the CI jobs passed.
* Allow force pushes to be able to squash commit already pushed.
* All this configuration need to include admin too.

Follow the steps below:
1. Go in your repo and click `Settings` on the right side.
2. Click `Branches` on the right side-bar and `Add rules`.
3. In the **Branch name pattern** field, put the name of the branch you want those rules to be applied on (in most of the case, `main`).
4. Select all the rules listed above and click on `Create` at the bottom.

> ### **Warning**:
> By default, job name is **build** but this name is editable in `.circleci/config.yml`.
> If you chose to replace this job name, you will need to update the github branch check feature configuration too.
> Below, steps to follow:
> 1. Go in your repo and click `Settings` on the right side.
> 2. Click `Branches` on the right side-bar and `Add rules`.
> 3. Click on `Edit`
> 4. Under `Require status checks to pass before merging`, search something like **ci/circleci: <my_job_name>**.
> 5. Click on `Save changes`.
