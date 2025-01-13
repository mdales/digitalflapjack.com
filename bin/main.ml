open Webplats

let thumbnail_loader page thumbnail_size _root _path _request =
  let path = Image.render_thumbnail page thumbnail_size in
  Dream.respond
    (In_channel.with_open_bin (Fpath.to_string path) (fun ic ->
         In_channel.input_all ic))

let snapshot_image_loader page image bounds _root _path _request =
  let path = Image.render_image page image Fit bounds in
  Dream.respond
    (In_channel.with_open_bin (Fpath.to_string path) (fun ic ->
         In_channel.input_all ic))

let general_thumbnail_loader ~retina page =
  match Page.original_section_title page with
  | "projects" ->
      let i = Option.get (Page.get_key_as_string page "icon") in
      snapshot_image_loader page i
        (if retina then (256, 256) else (128, 128))
  | _ -> thumbnail_loader page (if retina then 400 else 200)

let section_render sec =
  match Section.title sec with
  | "projects" -> Projects.render_section
  | "publications" -> Publications.render_section
  | _ -> Posts.render_section

let taxonomy_section_renderer taxonomy _sec =
  match Taxonomy.title taxonomy with
  | _ -> Posts.render_section
  
let taxonomy_renderer taxonomy =
  match Taxonomy.title taxonomy with
  | _ -> Renderer.render_taxonomy

let page_render page =
  match Page.original_section_title page with
  | "blog" | "weeknotes" -> Posts.render_page
  | "root" -> About.render_page
  | _ -> Renderer.render_page

let () =
  let website_dir =
    match Array.to_list Sys.argv with
    | [ _; path ] -> Fpath.v path
    | _ -> failwith "Expected one arg, your website dir"
  in

  let site = Site.of_directory website_dir in

  let toplevel =
    [
      Dream.get "/" (fun _ -> Index.render_index site |> Dream.html);
      Dream.get "/index.xml" (fun _ ->
          Rss.render_rss site
            (Site.sections site
            |> List.concat_map (fun sec ->
                   Section.pages sec |> List.map (fun p -> (sec, p)))
            |> List.sort (fun (_, a) (_, b) ->
                   Ptime.compare (Page.date b) (Page.date a)))
          |> Dream.html);
    ]
  in

  let static = Router.collect_static_routes site in

  let sections =
    List.concat_map
      (Router.routes_for_section ~thumbnail_loader:general_thumbnail_loader
         ~image_loader:snapshot_image_loader ~section_renderer:section_render
         ~page_renderer:page_render site)
      (Site.sections site)
  in

  let taxonomies =
    Router.routes_for_taxonomies ~thumbnail_loader:general_thumbnail_loader
      ~image_loader:snapshot_image_loader ~taxonomy_renderer ~taxonomy_section_renderer
      ~page_renderer:page_render site
  in

  let aliases = Router.routes_for_aliases site in

  Dream.log "Adding %d routes"
    (List.length (toplevel @ sections @ taxonomies @ aliases @ static));
  Dream.run ~error_handler:(Dream.error_template (Renderer.render_error site))
  @@ Dream.logger
  @@ Dream.router (toplevel @ sections @ taxonomies @ aliases @ static)
