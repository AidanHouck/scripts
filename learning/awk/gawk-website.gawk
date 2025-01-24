#!/usr/bin/env nix-shell
#! nix-shell -i "gawk -f"
#! nix-shell -p gawk

# serve a web page on localhost:8080
# usage: ./${0} some-page.html

# reference: http://tuxgraphics.org/~guido/scripts/awk-one-liner.html

BEGIN {
if (ARGC < 2) { print "Usage: $0 file.html"; exit 1 }
	Concnt = 1;
        while (1) {
        RS = ORS = "\r\n";
        HttpService = "/inet/tcp/8080/0/0";
        getline Dat < ARGV[1];
        Datlen = length(Dat) + length(ORS);
        while (HttpService |& getline ){
		if (ERRNO) { print "Connection error: " ERRNO; exit 1}
                print "client: " $0;
                if ( length($0) < 1 ) break;
        }
        print "HTTP/1.1 200 OK"             |& HttpService;
        print "Content-Type: text/html"     |& HttpService;
        print "Server: wwwawk/1.0"          |& HttpService;
        print "Connection: close"           |& HttpService;
        print "Content-Length: " Datlen ORS |& HttpService;
        print Dat                           |& HttpService;
        close(HttpService);
        print "OK: served file " ARGV[1] ", count " Concnt;
        Concnt++;
      }
}

