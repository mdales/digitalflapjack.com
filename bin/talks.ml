open Htmlit
open Webplats

let render_section site sec =
  let header = Render.render_head ~site ~sec () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in
  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
            El.section ~at:[At.role "main"] [
                El.h2 [El.txt "Under construction!"]
            ]
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
        (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"]*)
      ]
    ];
  ] in
  El.html [header;body]


let render_page site sec _previous_page page _next_page =
  let header = Render.render_head ~site ~sec ~page () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in
  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
        (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"]*)
      ]
    ];
  ] in
  El.html [header;body]
