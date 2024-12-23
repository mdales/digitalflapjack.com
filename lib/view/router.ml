open Astring
open Fpath

type image_loader_t =
  Page.t -> string -> int * int -> string -> string -> Dream.handler

let routes_for_frontmatter_image_list sec page (image_loader : image_loader_t) =
  List.concat_map
    (fun (i : Frontmatter.image) ->
      [
        (* non retina *)
        Dream.get
          (Section.url ~page sec ^ i.filename)
          (Dream.static ~loader:(image_loader page i.filename (720, 1200)) "");
        (* retina *)
        (let name, ext = Fpath.split_ext (Fpath.v i.filename) in
         let retina_name = Fpath.to_string name ^ "@2x" ^ ext in
         Dream.get
           (Section.url ~page sec ^ retina_name)
           (Dream.static
              ~loader:(image_loader page i.filename (720 * 2, 1200 * 2))
              ""));
      ])
    (Page.images page)

let routes_for_frontmatter_video_list sec page =
  List.map
    (fun filename ->
      Dream.get
        (Section.url ~page sec ^ filename)
        (fun _ ->
          Dream.respond
            (In_channel.with_open_bin
               (Fpath.to_string (Fpath.add_seg (Page.path page) filename))
               (fun ic -> In_channel.input_all ic))))
    (Page.videos page)

let routes_for_image_shortcodes sec page (image_loader : image_loader_t) =
  List.concat_map
    (fun (_, sc) ->
      match sc with
      | Shortcode.Image (filename, _, _) ->
          [
            Dream.get
              (Section.url ~page sec ^ filename)
              (Dream.static ~loader:(image_loader page filename (800, 600)) "");
            (let name, ext = Fpath.split_ext (Fpath.v filename) in
             let retina_name = Fpath.to_string name ^ "@2x" ^ ext in
             Dream.get
               (Section.url ~page sec ^ retina_name)
               (Dream.static
                  ~loader:(image_loader page filename (800 * 2, 600 * 2))
                  ""));
          ]
      | _ -> [])
    (Page.shortcodes page)

let routes_for_direct_shortcodes sec page =
  List.concat_map
    (fun (_, sc) ->
      match sc with
      | Shortcode.Video (r, None) -> [ r ]
      | Shortcode.Video (r, Some t) -> [ r; t ]
      | Shortcode.Audio r -> [ r ]
      | _ -> [])
    (Page.shortcodes page)
  |> List.map (fun filename ->
         Dream.get
           (Section.url ~page sec ^ filename)
           (fun _ ->
             Dream.respond
               (In_channel.with_open_bin
                  (Fpath.to_string (Fpath.add_seg (Page.path page) filename))
                  (fun ic -> In_channel.input_all ic))))

let collect_static_routes site =
  let website_dir = Site.path site in
  let website_static_dir = website_dir / "static" in
  let theme_static_dir =
    website_dir / "themes" / Site.hugo_theme site / "static"
  in

  let things_to_be_published =
    List.concat_map
      (fun static_dir ->
        Sys.readdir (Fpath.to_string static_dir)
        |> Array.to_list
        |> List.map (fun n -> static_dir / n))
      [ website_static_dir; theme_static_dir ]
  in

  List.map
    (fun path ->
      let basename = Fpath.basename path in
      match Sys.is_directory (Fpath.to_string path) with
      | true ->
          Dream.get
            (Printf.sprintf "/%s/**" basename)
            (Dream.static (Fpath.to_string (path / ".")))
      | false ->
          Dream.get ("/" ^ basename)
            (Dream.static
               ~loader:(fun _root _path _request ->
                 Dream.respond
                   (In_channel.with_open_bin (Fpath.to_string path) (fun ic ->
                        In_channel.input_all ic)))
               ""))
    things_to_be_published

let routes_for_aliases site =
  List.concat_map
    (fun sec ->
      List.concat_map
        (fun page ->
          List.map
            (fun alias ->
              Dream.get alias (fun r ->
                  Dream.redirect ~status:`Moved_Permanently r
                    (Section.url ~page sec)))
            (Page.aliases page))
        (Section.pages sec))
    (Site.sections site)

let routes_for_redirect_for_sans_slash sec page =
  let page_url = Section.url ~page sec in
  match String.is_suffix ~affix:"/" page_url with
  | false -> []
  | true ->
      let sans_slash =
        String.with_range ~len:(String.length page_url - 1) page_url
      in
      [
        Dream.get sans_slash (fun r ->
            Dream.redirect ~status:`Moved_Permanently r page_url);
      ]
