open Webplats

let thumbnail_loader page thumbnail_size _root _path request =
  let pathp = Image.render_thumbnail_lwt page thumbnail_size in
  Lwt.bind pathp (fun path ->
    Router.static_loader "/" (Fpath.to_string path) request
  )

let snapshot_image_loader page image bounds _root _path request =
  let pathp = Image.render_image_lwt page image Fit bounds in
  Lwt.bind pathp (fun path ->
    Router.static_loader "/" (Fpath.to_string path) request
  )

let general_thumbnail_loader ~retina page =
  match Page.original_section_title page with
  | "projects" ->
      let i = Option.get (Page.get_key_as_string page "icon") in
      snapshot_image_loader page i
        (if retina then (256, 256) else (128, 128))
  | _ -> thumbnail_loader page (if retina then 800 else 400)

let section_render sec =
  match Section.title sec with
  | "projects" -> Projects.render_section
  | "publications" -> Publications.render_section
  | "weeknotes" -> Weeknotes.render_section
  | "talks" -> Talks.render_section
  | _ -> Posts.render_section

let taxonomy_section_renderer taxonomy _sec =
  match Taxonomy.title taxonomy with
  | _ -> Posts.render_section

let taxonomy_renderer taxonomy =
  match Taxonomy.title taxonomy with
  | _ -> Renderer.render_taxonomy

let page_render page =
  match Page.original_section_title page with
  | "blog" -> Posts.render_page
  | "publications" -> Publications.render_page
  | "weeknotes" -> Weeknotes.render_page
  | "root" -> About.render_page
  | "talks" -> Talks.render_page
  | _ -> Renderer.render_page

let page_body page =
  match Page.original_section_title page with
  | "publications" -> Publications.render_body
  | _ -> Render.render_body

let () =
  let website_dir =
    match Array.to_list Sys.argv with
    | [ _; path ] -> Fpath.v path
    | _ -> failwith "Expected one arg, your website dir"
  in

  let site = Site.of_directory website_dir in

  (* As a temp thing, use the about page as the landing page *)
  let about_sec =
    Site.sections site
    |> List.filter (fun sec -> "website" = Section.title sec)
    |> List.hd
  in
  let about_page =
    Section.pages about_sec
    |> List.filter (fun page -> "About" = Page.title page)
    |> List.hd
  in

  let toplevel =
    [
      (* Dream.get "/" (fun _ -> Index.render_index site |> Dream.html); *)
      Dream.get "/" (fun _ ->
          About.render_page site about_sec None about_page None |> Dream.html);
      Dream.get "/index.xml" (fun _ ->
          Rss.render_rss site
            (Site.sections site
            |> List.concat_map (fun sec ->
                   Section.pages sec |> List.map (fun p -> (sec, p, page_body p)))
            |> List.sort (fun (_, a, _) (_, b, _) ->
                   Ptime.compare (Page.date b) (Page.date a)))
          |> Dream.respond ~headers:[ ("Content-Type", "application/rss+xml") ]);
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

  let port = Site.port site in

  Dream.log "Adding %d routes"
    (List.length (toplevel @ sections @ taxonomies @ aliases @ static));
  Dream.run ~error_handler:(Dream.error_template (Renderer.render_error site)) ~port
  @@ Dream.logger
  @@ Dream.router (toplevel @ sections @ taxonomies @ aliases @ static)
