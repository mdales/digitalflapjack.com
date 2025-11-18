open Webplats

let thumbnail_loader page thumbnail_size request =
  let pathp = Image.render_thumbnail_lwt page thumbnail_size in
  Lwt.bind pathp (fun path ->
      Router.static_loader "/" (Fpath.to_string path) request)

let snapshot_image_loader page image bounds request =
  let pathp = Image.render_image_lwt page image Fit bounds in
  Lwt.bind pathp (fun path ->
      Router.static_loader "/" (Fpath.to_string path) request)

let general_thumbnail_loader ~retina page =
  match Page.original_section_title page with
  | "projects" ->
      let i = Option.get (Page.get_key_as_string page "icon") in
      snapshot_image_loader page i (if retina then (256, 256) else (128, 128))
  | _ -> thumbnail_loader page (if retina then 800 else 400)

let section_render sec =
  match Section.title sec with
  | "projects" -> Projects.render_section
  | "publications" -> Publications.render_section
  | "weeknotes" -> Weeknotes.render_section
  | "talks" -> Talks.render_section
  | _ -> Posts.render_section

let taxonomy_section_renderer taxonomy _sec =
  match Taxonomy.title taxonomy with _ -> Posts.render_section

let taxonomy_renderer taxonomy =
  match Taxonomy.title taxonomy with _ -> Renderer.render_taxonomy

let page_renderer page =
  match Page.original_section_title page with
  | "blog" -> Posts.render_page
  | "publications" -> Publications.render_page
  | "weeknotes" -> Weeknotes.render_page
  | "root" -> About.render_page
  | "talks" -> Talks.render_page
  | _ -> Renderer.render_page

let page_body_renderer page =
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

  let overrides =
    (* Dream.get "/" (fun _ -> Index.render_index site |> Dream.html); *)
    Dream.get "/" (fun _ ->
        About.render_page site about_sec None about_page None |> Dream.html)
    :: []
  in

  let routes = Router.of_site
    ~section_renderer:section_render
    ~image_loader:snapshot_image_loader
    ~thumbnail_loader:general_thumbnail_loader
    ~taxonomy_section_renderer
    ~taxonomy_renderer
    ~page_renderer
    ~page_body_renderer
    site
  in

  let routes = overrides @ routes in

  let port = Site.port site in

  Dream.log "Adding %d routes" (List.length routes);
  Dream.run
    ~error_handler:(Dream.error_template (Renderer.render_error site))
    ~port
  @@ Dream.logger
  @@ Dream.router routes
