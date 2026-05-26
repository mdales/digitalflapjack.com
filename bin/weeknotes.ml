open Htmlit
open Webplats

let render_section site sec =
  let header = Render.render_head ~site ~sec () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in

  let sections = List.map (fun page ->
    let date = Renderer.ptime_to_str (Page.date page) in
    let url = Uri.to_string (Section.uri ~page sec) in
    El.div ~at:[At.class' "blogcontents__item"] [
      El.ul ~at:[At.class' "leaders"] [
        El.li [
          El.span [
            El.a ~at:[At.href url] [
              El.txt (Page.title page)
            ]
          ];
          El.span [
            El.txt date
          ]

        ]
      ]
    ]
  ) (Section.pages sec) in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.section ~at:[At.role "main"] [
            El.div ~at:[At.class' "blogcontents"] sections
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

let render_page site sec previous_page page next_page =
  let header = Render.render_head ~site ~sec ~page () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in
  let raw_title = (Page.title page) in
  let is_old_weeknotes = String.starts_with ~prefix:"Weeknotes:" raw_title in
  let content = Render.render_body page in
  let date = Renderer.ptime_to_str (Page.date page) in

  let article_head = match is_old_weeknotes with
  | true -> [El.h1 ~at:[At.class' "title"]  [El.txt raw_title]]
  | false -> [
    El.h1 ~at:[At.class' "title"] [El.txt (Printf.sprintf "Weeknotes: %s" raw_title)];
    El.p [El.txt date];
  ] in

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

  let article = article_head @
    [
      El.div ~at:[At.class' "content"] [El.unsafe_raw content];
    ] @ tags
  in

  let nav_links = Renderer.navigation_links sec previous_page next_page in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.class' "article"] [
          El.article article;
          nav_links
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
        (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"]*)
      ]
    ];
  ] in
  El.html [header;body]
