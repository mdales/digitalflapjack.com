open Webplats

let get_cache_dir env =
  let p =
    match Sys.getenv_opt "WEBPLATS_CACHE_DIR" with
    | Some x -> x
    | None -> (
        match Sys.getenv_opt "TMPDIR" with Some x -> x | None -> "/tmp")
  in
  Eio.Path.(env#fs / p)

let thumbnail_loader process_mgr cache_dir page thumbnail_size =
  Image.render_thumbnail process_mgr cache_dir page thumbnail_size

let snapshot_image_loader process_mgr cache_dir page image bounds =
  Image.render_image process_mgr cache_dir page image Fit bounds

let diagram_loader process_mgr cache_dir page code =
  Image.render_diagram process_mgr cache_dir page code

let general_thumbnail_loader ~process_mgr ~cache_dir ~retina page =
  match Page.original_section_title page with
  | "projects" ->
      let i = Option.get (Page.get_key_as_string page "icon") in
      snapshot_image_loader process_mgr cache_dir page i
        (if retina then (256, 256) else (128, 128))
  | _ ->
      thumbnail_loader process_mgr cache_dir page (if retina then 800 else 400)

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

let log_error ex = Printf.eprintf "Server error: %s\n%!" (Printexc.to_string ex)

let handler routes _socket req _body =
  let open Cohttp_eio in
  let request_path = Http.Request.resource req in
  let uri = Uri.of_string request_path in
  (* let path = Uri.path uri in *)
  let meth = Http.Request.meth req in
  let status, response =
    match meth with
    | `GET -> (
        match List.assoc_opt uri routes with
        | Some handler -> (`OK, handler req)
        | None ->
            ( `Not_found,
              Server.respond_string ~status:`Not_found ~body:"Not found\n" () ))
    | _ ->
        ( `Not_found,
          Server.respond_string ~status:`Not_found ~body:"Not found\n" () )
  in
  Printf.printf "%s %s %s\n%!"
    (Http.Method.to_string meth)
    request_path
    (Http.Status.to_string status);
  response

let () =
  Eio_main.run @@ fun env ->
  let cache_dir = get_cache_dir env in
  Eio.Switch.run @@ fun sw ->
  let website_dir =
    match Array.to_list Sys.argv with
    | [ _; path ] ->
        if Filename.is_relative path then Eio.Path.(env#cwd / path)
        else Eio.Path.(env#fs / path)
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

  let overrides : Router.route list =
    {
      uri = Uri.of_string "/";
      handler =
        (let body =
           About.render_page site about_sec None about_page None
           |> Htmlit.El.to_string ~doctype:true
         in
         fun _ -> Cohttp_eio.Server.respond_string ~status:`OK ~body ());
    }
    :: []
  in

  let routes =
    Router.of_site ~section_renderer:section_render
      ~image_loader:(snapshot_image_loader env#process_mgr cache_dir)
      ~thumbnail_loader:
        (general_thumbnail_loader ~process_mgr:env#process_mgr ~cache_dir)
      ~diagram_loader:(diagram_loader env#process_mgr cache_dir)
      ~taxonomy_section_renderer ~taxonomy_renderer ~page_renderer
      ~page_body_renderer site
  in

  let routes =
    overrides @ routes |> List.map (fun p -> (p.Router.uri, p.Router.handler))
  in

  let socket =
    Eio.Net.listen env#net ~sw ~backlog:128 ~reuse_addr:true
      (`Tcp (Eio.Net.Ipaddr.V4.loopback, 8080))
  in
  Printf.printf "Listening on http://localhost:8080\n%!";
  Cohttp_eio.Server.run socket ~on_error:log_error
    (Cohttp_eio.Server.make ~callback:(handler routes) ())
