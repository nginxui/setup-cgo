// Opens an SQLite database through the cgo driver and prints what it holds,
// which proves the C toolchain built and linked SQLite for the target.
package main

import (
	"database/sql"
	"fmt"
	"os"
	"runtime"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := sql.Open("sqlite3", "file::memory:")
	if err != nil {
		fail(err)
	}
	defer db.Close()
	if _, err := db.Exec("CREATE TABLE t (n INTEGER); INSERT INTO t VALUES (40), (2)"); err != nil {
		fail(err)
	}
	var version string
	var sum int
	if err := db.QueryRow("SELECT sqlite_version(), (SELECT sum(n) FROM t)").Scan(&version, &sum); err != nil {
		fail(err)
	}
	if sum != 42 {
		fail(fmt.Errorf("sum is %d", sum))
	}
	fmt.Printf("sqlite %s on %s/%s\n", version, runtime.GOOS, runtime.GOARCH)
}

func fail(err error) {
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}
