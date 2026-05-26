open Htmlit
open Webplats

let render_page site sec _previous_page page _next_page =
  let header = Render.render_head ~site ~sec ~page () in
  let topbar = Renderer.render_header (Section.uri sec) (Section.title sec) in
  let content_body = Render.render_body page in
  let thumbnail_uri = (Section.uri ~page ~resource:"thumbnail.jpg" sec) in
  let thumbnail_2x_uri = (Section.uri ~page ~resource:"thumbnail@2x.jpg" sec) in
  let body = El.body [
    El.div ~at:[At.class' "almostall"] [
      El.div ~at:[At.class' "greenbar"; At.id "topbar"] [];

      El.div ~at:[At.class' "page"] [
        topbar;
        El.div ~at:[At.id "content"] [
          El.div ~at:[At.class' "article"] [
            El.article [
              El.div ~at:[At.class' "flex"] [
                El.div ~at:[At.id "prose"] [
                  El.h1 [El.txt (Page.title page)];
                  El.unsafe_raw content_body;
                ];
                El.div ~at:[At.style "position: relative; width:404px;"] [
                  El.div ~at:[
                    At.style "position: absolute; z-index: 100;";
                    At.id "mepic";
                  ] [
                    El.h2 [El.unsafe_raw "&nbsp;"];
                    El.img ~at:[
                      At.class' "aboutme";
                      At.src (Uri.to_string thumbnail_uri);
                      At.v "srcset" (
                        Printf.sprintf "%s 2x, %s 1x" (Uri.to_string thumbnail_2x_uri) (Uri.to_string thumbnail_uri)
                      )
                    ] ();
                  ];
                  El.div ~at:[
                    At.id "sidebar";
                    At.style "position: absolute; height: 100%; z-index: 10;";
                  ] [
                    El.h2 [El.unsafe_raw "&nbsp;"];
                    El.canvas ~at:[
                      At.id "side";
                      At.width 400;
                      At.height 800;
                    ] []
                  ]
                ]
              ]
            ]
          ]
        ]
      ];
      El.div ~at:[At.id "footer"] [];
      El.div ~at:[At.class' "greenbar"; At.id "bottombar"] [
        (* El.span [El.txt "Digital Flapjack Ltd, UK Company 06788544"] *)
      ]
    ];
  ]
  in
  let script = El.script [El.unsafe_raw {|
  let start;


  function tick(timestamp) {
    if (start === undefined) {
      start = timestamp;
    }
    const t = timestamp - start;

    const canvas = document.getElementById("side");
    const ctx = canvas.getContext("2d");

    const step = (canvas.width - 20) / 10;
    const width = Math.ceil(canvas.width / step);
    const height = Math.ceil(canvas.height / step);

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.strokeStyle = "rgb(127 180 0 / 50%)";
    ctx.fillStyle = "rgb(127 180 0 / 50%)";

    const z = 10 + (Math.sin(t / 500000) * 5);
    const d = 10 + (Math.cos(t / 500000) * 5);

    for (y = 0; y < height; y ++) {
      for (x = 0; x < width; x ++) {

        const c = (Math.sin(Math.sin((x + (t / 100)) / z)) +
          Math.sin(Math.sin((y + (t/100)) / d))) * 5;
        const r = ((c + 8) / 4) ;

        if (r > 0) {
          ctx.beginPath();
          ctx.lineWidth = (r / 2);
          ctx.arc(
            (x * step) + (step / 2) - 5,
            (y * step) + (step / 2) - 5,
            r, 0, Math.PI * 2, 0);
          ctx.fill();
        }
      }
    }

    window.requestAnimationFrame(tick);
  };

  document.addEventListener('DOMContentLoaded', function() {
    const canvas = document.getElementById("side");
    const parent = canvas.parentNode;
    canvas.width = parent.offsetWidth;
    canvas.height = parent.offsetHeight;

    window.requestAnimationFrame(tick);
  });
  |}] in
  El.html [header;body;script]
