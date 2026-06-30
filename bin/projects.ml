open Htmlit
open Webplats

let render_section site sec =
  let header = Render.render_head ~site ~sec () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in

  let projects =
    List.map
      (fun page ->
        let icon = Page.get_key_as_string page "icon" in
        let src = Page.get_key_as_string page "source" in
        let content = Page.get_key_as_bool page "content" in
        let has_content = match content with None -> false | Some x -> x in
        let has_source = match src with None -> false | Some _ -> true in

        let urlbase = Uri.to_string (Section.uri ~page sec) in

        let image =
          match icon with
          | Some filename -> (
              let _, ext = Fpath.split_ext (Fpath.v filename) in
              match ext with
              | ".svg" ->
                  El.div
                    ~at:
                      [
                        At.class' "projecticon";
                        At.style
                          ("background-image: url(" ^ urlbase ^ "thumbnail.svg");
                      ]
                    []
              | _ ->
                  El.img
                    ~at:
                      [
                        At.class' "projecticon";
                        At.src (urlbase ^ "thumbnail.jpg");
                        At.v "srcset"
                          (urlbase ^ "thumbnail@2x.jpg 2x, " ^ urlbase
                         ^ "thumbnail.jpg 1x");
                      ]
                    ())
          | None -> El.div ~at:[ At.class' "projecticon" ] []
        in

        let prose =
          match Page.synopsis page with Some prose -> prose | None -> ""
        in

        let inner =
          El.div
            [
              image;
              El.h2 [ El.txt (Page.title page) ];
              El.p
                ~at:[ At.class' "projectdate" ]
                [ El.txt (Renderer.ptime_to_str (Page.date page)) ];
              El.p [ El.txt prose ];
            ]
        in

        let wrapped_inner =
          match has_source || has_content with
          | true ->
              let url =
                match src with
                | Some url -> url
                | None -> Uri.to_string (Section.uri ~page sec)
              in
              El.a ~at:[ At.href url ] [ inner ]
          | false -> inner
        in

        El.div ~at:[ At.class' "project" ] [ wrapped_inner ])
      (Section.pages sec)
  in

  let body =
    El.body
      [
        El.div
          ~at:[ At.class' "almostall" ]
          [
            El.div ~at:[ At.class' "greenbar"; At.id "topbar" ] [];
            El.div
              ~at:[ At.class' "page" ]
              [
                topbar;
                El.div
                  ~at:[ At.id "content" ]
                  [ El.div ~at:[ At.class' "projectlist" ] projects ];
              ];
            El.div ~at:[ At.id "footer" ] [];
            El.div
              ~at:[ At.class' "greenbar"; At.id "bottombar" ]
              [ El.span [ El.txt "Digital Flapjack Ltd, UK Company 06788544" ] ];
          ];
      ]
  in
  El.html [ header; body ]
