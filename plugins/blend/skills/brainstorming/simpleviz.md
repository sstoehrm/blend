# Using simpleviz

EDN-driven graph viewer with auto-layout and live reload
([sstoehrm/simpleviz](https://github.com/sstoehrm/simpleviz)).

## Setup and serving

```bash
dir="$(scripts/ensure-simpleviz.sh)"   # downloads latest release on first run (needs gh + tar)
(cd "$dir" && bb serve /abs/path/to/graph.edn)            # http://localhost:7373
(cd "$dir" && bb serve /abs/path/to/graph.edn --port 9000) # if 7373 is taken
```

Run the script via its absolute path (this file's directory + `/scripts/`).
Requires [babashka](https://babashka.org/) (`bb`) on PATH. The viewer
live-reloads on every edit to the `.edn` file — serve once, keep editing.
Delete `scripts/simpleviz/` to force re-download of a newer release.

## EDN format

```clojure
{:nodes {:api {:name "API"            ; display name (defaults to the key)
               :type "service"        ; free-form; determines color, shown as (type)
               :lang "clojure"}}      ; any other attr: inspector panel only
 :edges {[:web :api]                  ; key: endpoints; order defines left/right;
                                      ; the same pair must not appear twice (either order)
         {:direction :->              ; :-> | :<- | :<-> | :- (default :-)
          :name "REST"
          :type "http"}}
 :boxes {:backend                     ; key is the box id (and display name)
         {:type "zone"                ; colors the box (separate palette)
          :components #{:api :db}}}}  ; node and/or box ids; boxes nest
```

Identifiers: keywords or strings. Type colors are stable across restarts and
edits. Invalid references, duplicate box memberships, or containment cycles
don't break rendering — the element is skipped with a warning banner; a parse
error keeps the last good render. So save early, save often.
