module github.com/cisco-app-networking/networkservicemesh/applications/nsmrs

go 1.13

require (
	github.com/golang/protobuf v1.3.2
	github.com/networkservicemesh/networkservicemesh/applications/nsmrs v0.0.0-00010101000000-000000000000
	github.com/networkservicemesh/networkservicemesh/controlplane/api v0.3.0
	github.com/networkservicemesh/networkservicemesh/pkg v0.0.0-00010101000000-000000000000
	github.com/networkservicemesh/networkservicemesh/utils v0.0.0-00010101000000-000000000000
	github.com/onsi/gomega v1.7.0
	github.com/pkg/errors v0.8.1
	github.com/sirupsen/logrus v1.4.2
	github.com/uber/jaeger-lib v2.2.0+incompatible // indirect
	google.golang.org/grpc v1.27.0
)

replace (
	github.com/census-instrumentation/opencensus-proto v0.1.0-0.20181214143942-ba49f56771b8 => github.com/census-instrumentation/opencensus-proto v0.0.3-0.20181214143942-ba49f56771b8
	github.com/networkservicemesh/networkservicemesh/applications/nsmrs => ./
	github.com/networkservicemesh/networkservicemesh/controlplane => ../../controlplane
	github.com/networkservicemesh/networkservicemesh/controlplane/api => ../../controlplane/api
	github.com/networkservicemesh/networkservicemesh/dataplane/api => ../../dataplane/api
	github.com/networkservicemesh/networkservicemesh/pkg => ../../pkg
	github.com/networkservicemesh/networkservicemesh/sdk => ../../sdk
	github.com/networkservicemesh/networkservicemesh/side-cars => ../../side-cars
	github.com/networkservicemesh/networkservicemesh/utils => ../../utils
)
