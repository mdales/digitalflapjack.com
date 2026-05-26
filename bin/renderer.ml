open Htmlit
open Webplats

let render_header _uri _title =
  El.div ~at:[At.id "header"] [
    El.div [
      El.a ~at:[At.href "/"] [
        El.div ~at:[At.class' "logo"] []
      ]
    ];
    El.div [
      El.h1 [
        El.txt "Tech notes by Michael Winston Dales"
      ];
      El.nav [
        El.ul ~at:[At.id "headernav"]
          (List.map (fun (url, label) ->
            El.li [
              El.a ~at:[At.href url] [
                El.txt label
              ]
            ]
          ) [
          ("/", "Home");
          ("/blog/", "Blog");
          ("/projects/", "Projects");
          ("/publications/", "Publications");
          ("/talks/", "Talks");
          ("/weeknotes/", "Weeknotes");
          (*("/about/", "About");*)
          ])
      ]
    ]
  ]

let months = [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sept" ; "Oct" ; "Nov"; "Dec" |]

let ptime_to_str (t : Ptime.t) : string =
  let ((year, month, day), _) = Ptime.to_date_time t in
  Printf.sprintf "%s %d, %d" months.(month - 1) day year

(* let render_page_templte header topbar =
  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];

      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.class' "content"] [

        ]
      ]
    ]
  ]
  in
  El.html [header;body] *)

(*
let render_section site sec =
  let header = Render.render_head ~site ~sec () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in
  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
        ]
      ];
      El.div ~at:[At.id "footer"] []
    ];
    El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
      El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"]
    ]
  ] in
  El.html [header;body] *)


let navigation_links sec previous_page next_page =
  let previous_page = match previous_page with
  | Some page -> [
    El.a ~at:[At.href (Uri.to_string (Section.uri ~page sec))] [
      El.unsafe_raw "&#10094; ";
      El.txt (Page.title page);
    ]
  ]
  | None -> []
  and next_page = match next_page with
  | Some page -> [
    El.a ~at:[At.href (Uri.to_string (Section.uri ~page sec))] [
      El.txt (Page.title page);
      El.unsafe_raw " &#10095;";
    ]
  ]
  | None -> []
  in
  El.div ~at:[At.class' "paginationflex"] (List.concat_map Fun.id [previous_page;next_page])


let render_taxonomy site taxonomy =
  let header = Render.render_head ~site () in
  let topbar = render_header (Taxonomy.uri taxonomy) (Taxonomy.title taxonomy) in

  let secs = List.map (fun sec ->
    El.li [
      El.a ~at:[At.href (Uri.to_string (Section.uri sec))] [
        El.txt (Section.title sec)
      ];
      El.txt (Printf.sprintf "%d items" (List.length (Section.pages sec)))
    ]
  ) (Taxonomy.sections taxonomy) in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.ul secs
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
  let topbar = render_header (Section.uri sec) (Section.title sec) in

  let navlinks = navigation_links sec previous_page next_page in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.div ~at:[At.class' "article"] [
            El.article ([
              El.h1 ~at:[At.class' "title"] [El.txt (Page.title page)];
              El.p ~at:[At.class' "date"] [El.txt (ptime_to_str (Page.date page))];
              El.div ~at:[At.class' "content"] [El.unsafe_raw (Render.render_body page)]
            ]);
            navlinks
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


let render_error site _error _debug_info suggested_response =
  let status = Dream.status suggested_response in
  let code = Dream.status_to_int status
  and reason = Dream.status_to_string status in

  let header = Render.render_head ~site () in
  let topbar = render_header (Section.uri (Site.toplevel site)) (Section.title (Site.toplevel site)) in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.div ~at:[At.class' "article"] [
            El.article [
              El.h2 [El.txt (Printf.sprintf "%d: %s" code reason)]
            ]
          ]
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
        (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"]*)
      ]
    ];
  ] in
  let html = El.html [header;body] |> El.to_string ~doctype:true in

  Dream.set_header suggested_response "Content-Type" Dream.text_html;
  Dream.set_body suggested_response html;
  Lwt.return suggested_response
