open Htmlit
open Webplats

let render_section site sec =
  let header = Render.render_head ~site ~sec () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in

  let pagelist = List.map (fun page ->
    El.div ~at:[At.class' "blogcontents__item"] [
      El.ul ~at:[At.class' "leaders"] [
        El.li [
          El.span [
            El.a ~at:[At.href (Uri.to_string (Section.uri ~page sec))] [
              El.txt (Page.title page)
            ]
          ];
          El.span [
            El.txt (Renderer.ptime_to_str (Page.date page))
          ]
        ]
      ];
      El.div ~at:[At.class' "blogcontents__item__inner"] [];
    ]
  ) (Section.pages sec) in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.section ~at:[At.role "main"] [
            El.div ~at:[At.class' "blogcontents"] pagelist
          ]
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
      (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"] *)
      ]
    ];
  ] in
  El.html [header; body]

let render_page site sec previous_page page next_page =
  let header = Render.render_head ~site ~sec ~page () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in

  let tags = match (Page.tags page) with
  | [] -> []
  | tags -> (
    let items = List.map (fun tag ->
      let term_for_url = String.map (fun c -> match c with ' ' -> '-' | x -> x) tag in
      El.a ~at:[At.href (Printf.sprintf "/tags/%s/" term_for_url)] [El.txt tag]
    ) tags in
    let rec loop = function
    | [] | [_] as l -> l
    | x::xs -> x :: El.txt ", " :: loop xs
    in
    let seperated_items = loop items in
    [El.p (El.txt "Tags: " :: seperated_items)]
  ) in

  let navlinks = Renderer.navigation_links sec previous_page next_page in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.div ~at:[At.class' "article"] [
            El.article ([
              El.h1 ~at:[At.class' "title"] [El.txt (Page.title page)];
              El.p ~at:[At.class' "date"] [El.txt (Renderer.ptime_to_str (Page.date page))];
            ] @ tags @ [
              El.div ~at:[At.class' "content"] [El.unsafe_raw (Render.render_body page)]
            ]);
            navlinks
          ]
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
        (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"] *)
      ]
    ];
  ] in
  El.html [header;body]
