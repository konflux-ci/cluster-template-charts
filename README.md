# cluster-template-charts
Helm Charts for use with the
[cluster-templates-operator](https://github.com/stolostron/cluster-templates-operator/).
Refer to the Operator's documentation for more information.

To install a chart/create a cluster (and infra/iam):

```shell
helm install --wait --wait-for-jobs --timeout 20m my-cluster <chart-dir>
```

To uninstall a chart/destroy a cluster (and infra/iam):

```shell
helm uninstall --timeout 20m my-cluster
```

## Releases

A GitHub Actions [workflow](.github/workflows/release.yaml) is used to automatically release new
charts upon merge to the `main` branch.

The chart repository is hosted with GitHub Pages and located at
https://konflux-ci.dev/cluster-template-charts.
