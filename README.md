# What's this
- for studying grpc

# reference
- [grpc quickstart guide](https://grpc.io/docs/languages/go/quickstart/)

# feature
- GetFeature [Simple RPC](https://grpc.io/docs/languages/go/basics/#simple-rpc)
- ListFeatures [Server-side streaming RPC](https://grpc.io/docs/languages/go/basics/#server-side-streaming-rpc)
- RecordRoute [Client-side streaming RPC](https://grpc.io/docs/languages/go/basics/#client-side-streaming-rpc)
- RouteChat [Bidirectional streaming RPC](https://grpc.io/docs/languages/go/basics/#bidirectional-streaming-rpc)

# how to implement
1. create `.proto` file like `simple_grpc.proto`
1. run 
    ```go
    protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    simplegrpc/simple_grpc.proto
    ```
1. server implements `SimpleGrpcServer interface` and client implements `SimpleGrpcClient interface`. These files are in `simplegrpc/simple_grpc_grpc.pb.go`
1. start the server
    ```go
    grpcServer := grpc.NewServer(opts...)
	pb.RegisterSimpleGrpcServer(grpcServer, newServer())
	grpcServer.Serve(lis)
    ```
1. create the channel on client
    ```go
    var opts []grpc.DialOption
    conn, err := grpc.Dial(*serverAddr, opts...)
    if err != nil {
    ...
    }
    defer conn.Close()
    client := pb.NewRouteGuideClient(conn)
    ```
1. client can call our service methods via `client` val

# how to run
- run the server `go run server/server.go`
- run the client `go run client/client.go`

<details>
<summary>you will see following outputs</summary>

```text
Getting feature for point (409146138, -746188906)
name:"Berkshire Valley Management Area Trail, Jefferson, NJ, USA" location:<latitude:409146138 longitude:-746188906 >
Getting feature for point (0, 0)
location:<>
Looking for features within lo:<latitude:400000000 longitude:-750000000 > hi:<latitude:420000000 longitude:-730000000 >
name:"Patriots Path, Mendham, NJ 07945, USA" location:<latitude:407838351 longitude:-746143763 >
...
name:"3 Hasta Way, Newton, NJ 07860, USA" location:<latitude:410248224 longitude:-747127767 >
Traversing 56 points.
Route summary: point_count:56 distance:497013163
Got message First message at point(0, 1)
Got message Second message at point(0, 2)
Got message Third message at point(0, 3)
Got message First message at point(0, 1)
Got message Fourth message at point(0, 1)
Got message Second message at point(0, 2)
Got message Fifth message at point(0, 2)
Got message Third message at point(0, 3)
Got message Sixth message at point(0, 3)
```

</details>