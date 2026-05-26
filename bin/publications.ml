open Htmlit
open Webplats

let render_pub_body show_abstract sec_opt page =
  let authorslist = match Page.get_key_as_yaml page "authors" with
  | Some yaml -> (
    match yaml with
    | `A lst -> (
      List.concat_map (fun yamldict ->
        match yamldict with
        | `O assoc -> (
          match (List.assoc_opt "name" assoc) with
          | Some nameval -> (
            match nameval with
            | `String name -> [El.txt name]
            | _ -> []
          )
          | None -> []
        )
        | _ -> []
      ) lst
    )
    | _ -> []
  )
  | None -> []
  in

  let pubtype = match Page.get_key_as_string page "type" with
  | Some name -> [El.txt name]
  | None -> []
   in

  let conf = match Page.get_key_as_string_dict page "conference" with
  | [] -> (
    match Page.get_key_as_string_dict page "where" with
    | [] -> [El.txt "published on "]
    | where -> (
      let url = List.assoc "url" where in
      [
        El.txt " on ";
        El.a ~at:[At.href url] [El.txt (List.assoc "title" where)]
      ]
    )
  )
  | conf -> (
    let title = List.assoc "title" conf in
    match List.assoc_opt "url" conf with
    | Some url -> [
      El.txt " in ";
      El.a ~at:[At.href url] [ El.txt title];
    ]
    | None -> [El.txt title]
  )
  in

  let opt_link key label href_fn =
      match Page.get_key_as_string page key with
      | Some url -> [
          El.txt " | ";
          El.a ~at:[At.href (href_fn url)] [El.txt label]
        ]
      | None -> []
  in

  let links = List.concat_map Fun.id [
    opt_link "paper"  "Download" (fun url -> Page.url_name page ^ "/" ^ url);
    opt_link "poster" "Poster"   (fun url -> Page.url_name page ^ "/" ^ url);
    opt_link "online" "Online"   Fun.id;
    opt_link "talk"   "Talk"     Fun.id;
  ] in

  let abstract = match show_abstract with
  | false -> []
  | true -> [
    El.div ~at:[At.class' "content"] [
      El.b [El.txt "Abstract:"];
      El.unsafe_raw (Render.render_body page);
    ]
  ]
  in

  [
    El.div ~at:[At.class' "paper"] [
      El.p ([
        El.span ~at:[At.class' "title"] [
          match sec_opt with
          | Some sec -> (
            El.a ~at:[At.href (Uri.to_string (Section.uri ~page sec))] [
              El.txt (Page.title page)
            ]
          )
          | None -> El.txt (Page.title page)
        ];
        El.br ();
        El.span ~at:[At.class' "authors"] authorslist;
        El.br ();
      ] @ pubtype @ conf @ [
        El.txt ", ";
        El.txt (Renderer.ptime_to_str (Page.date page));
        El.br ();
      ] @ links)
    ]
  ] @ abstract

let render_body page =
  let el = render_pub_body true None page in
  El.to_string ~doctype:false (El.div el)

let render_section site sec =
  let header = Render.render_head ~site ~sec () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in

  let paperslist = List.concat_map (fun page ->
    render_pub_body false (Some sec) page
  ) (Section.pages sec) in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.h1 [El.txt "Papers and Publications"];
          El.div ~at:[At.class' "paperslist"] paperslist
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
      (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"] *)
      ]
    ];
  ] in
  El.html [header;body]


let render_page site sec previous_page page next_page =
  let header = Render.render_head ~site ~sec ~page () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in

  let nav_links = Renderer.navigation_links sec previous_page next_page in

  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];
      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.div ~at:[At.class' "article"] [
            El.article (render_pub_body true None page);
            nav_links
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
