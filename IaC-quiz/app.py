from flask import Flask, request, render_template, redirect, url_for, session, make_response
from datetime import datetime, timedelta
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont
import os
import random

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "change-me-please")
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = timedelta(seconds=0)  # disable static cache during dev

# ======== Kubernetes Quiz questions ========
QUESTIONS = [
  {"id": 1,  "question": "What is a Pod in Kubernetes?", "options": ["A single container only", "The smallest deployable unit that can contain one or more containers", "A Kubernetes node", "A storage volume"], "answer": 1},
  {"id": 2,  "question": "Which object maintains desired state of Pods via ReplicaSets?", "options": ["DaemonSet", "Deployment", "Service", "ConfigMap"], "answer": 1},
  {"id": 3,  "question": "Which Service type exposes the app externally using a port on each node?", "options": ["ClusterIP", "NodePort", "LoadBalancer", "ExternalName"], "answer": 1},
  {"id": 4,  "question": "What is the default Service type?", "options": ["ClusterIP", "NodePort", "LoadBalancer", "Headless"], "answer": 0},
  {"id": 5,  "question": "Which controller ensures one Pod per node?", "options": ["Deployment", "ReplicaSet", "StatefulSet", "DaemonSet"], "answer": 3},
  {"id": 6,  "question": "Where does 'kubectl logs' read from?", "options": ["API Server DB", "Container runtime on the node", "etcd directly", "Ingress controller"], "answer": 1},
  {"id": 7,  "question": "List all Pods in all namespaces", "options": ["kubectl get pods", "kubectl get pods -A", "kubectl get ns", "kubectl get all -n default"], "answer": 1},
  {"id": 8,  "question": "Purpose of a ConfigMap?", "options": ["Store sensitive data", "Store non-confidential configuration data", "Provide persistent storage", "Schedule Pods"], "answer": 1},
  {"id": 9,  "question": "Resource for mounting sensitive data?", "options": ["ConfigMap", "Secret", "PersistentVolume", "ServiceAccount"], "answer": 1},
  {"id": 10, "question": "Probe that checks if app is ready to receive traffic?", "options": ["livenessProbe", "readinessProbe", "startupProbe", "healthProbe"], "answer": 1},
  {"id": 11, "question": "Role of kube-scheduler?", "options": ["Schedule Pods onto nodes", "Manage container runtime", "Expose services", "Store cluster state"], "answer": 0},
  {"id": 12, "question": "Which component stores cluster state?", "options": ["kubelet", "etcd", "controller-manager", "kube-proxy"], "answer": 1},
  {"id": 13, "question": "What does a Namespace provide?", "options": ["Physical node isolation", "Logical isolation within a cluster", "Network policy", "Storage abstraction"], "answer": 1},
  {"id": 14, "question": "Which object provides stable network identity and DNS for a set of Pods?", "options": ["Deployment", "Service", "Ingress", "Job"], "answer": 1},
  {"id": 15, "question": "Which command describes details of a Pod?", "options": ["kubectl get pod mypod", "kubectl logs mypod", "kubectl describe pod mypod", "kubectl edit pod mypod"], "answer": 2},
  {"id": 16, "question": "Which controller is best for ordered, sticky identities and persistent storage per replica?", "options": ["Deployment", "ReplicaSet", "StatefulSet", "CronJob"], "answer": 2},
  {"id": 17, "question": "Which probe restarts a container if it becomes unhealthy?", "options": ["readinessProbe", "livenessProbe", "startupProbe", "execProbe"], "answer": 1},
  {"id": 18, "question": "What does kube-proxy do?", "options": ["Schedules Pods", "Maintains network rules and Service virtual IPs", "Stores cluster state", "Runs container runtime"], "answer": 1},
  {"id": 19, "question": "Which object lets you mount persistent storage into Pods?", "options": ["ConfigMap", "Secret", "PersistentVolumeClaim", "ServiceAccount"], "answer": 2},
  {"id": 20, "question": "Which resource type configures L7 HTTP routing into the cluster in modern Kubernetes?", "options": ["EndpointSlice", "Gateway API (HTTPRoute)", "ReplicaSet", "DaemonSet"], "answer": 1}
]


# ======== Helpers for certificate rendering ========
def _font(path_candidates, size):
    for p in path_candidates:
        if os.path.exists(p):
            return ImageFont.truetype(p, size=size)
    # fallback to PIL default if nothing found
    return ImageFont.load_default()

# adjust to your deployed font locations as needed
FONT_BOLD_CANDIDATES = [
    os.path.join('static', 'fonts', 'DejaVuSans-Bold.ttf'),
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
]
FONT_REG_CANDIDATES = [
    os.path.join('static', 'fonts', 'DejaVuSans.ttf'),
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
]

def build_certificate_image(name: str, date_str: str) -> Image.Image:
    bg_path = os.path.join(app.static_folder, 'certificate_bg.png')
    im = Image.open(bg_path).convert('RGBA')
    w, h = im.size
    draw = ImageDraw.Draw(im)

    name = name.upper().strip()
    max_name_width = int(w * 0.72)
    size = 80
    while size >= 80:
        f_try = _font(FONT_BOLD_CANDIDATES, size)
        bbox = draw.textbbox((0, 0), name, font=f_try)
        if (bbox[2] - bbox[0]) <= max_name_width:
            font_name = f_try
            break
        size -= 4
    else:
        font_name = _font(FONT_BOLD_CANDIDATES, 60)

    font_date = _font(FONT_REG_CANDIDATES, 56)

    name_x = w // 2
    name_y = int(h * 0.460)
    date_x = int(w * 0.130)
    date_y = int(h * 0.750)

    draw.text((name_x, name_y), name, fill=(0, 0, 0), font=font_name, anchor='mm')
    draw.text((date_x, date_y), date_str, fill=(0, 0, 0), font=font_date, anchor='lm')

    return im

def _image_bytes(name: str, date_str: str) -> bytes:
    img = build_certificate_image(name, date_str)
    buf = BytesIO()
    img.save(buf, format='PNG')
    return buf.getvalue()

# ======== Routes ========
@app.route("/", methods=["GET", "POST"])
def capture_name():
    if request.method == "POST":
        name = request.form.get("participant_name", "").strip()
        if not name:
            return render_template("name.html", error="Please enter your name.")
        session["participant_name"] = name

        # Create a randomized quiz order for this participant
        randomized = QUESTIONS[:]
        random.shuffle(randomized)
        session["quiz_questions"] = randomized

        return redirect(url_for("quiz"))
    return render_template("name.html")

@app.route("/quiz")
def quiz():
    if "participant_name" not in session:
        return redirect(url_for("capture_name"))

    questions = session.get("quiz_questions", QUESTIONS)
    return render_template("quiz.html", questions=questions)

@app.route("/submit", methods=["POST"])
def submit():
    if "participant_name" not in session:
        return redirect(url_for("capture_name"))

    questions = session.get("quiz_questions", QUESTIONS)
    score = 0
    total = len(questions)
    incorrect_answers = []

    for q in questions:
        ans = request.form.get(f"q{q['id']}")
        if ans is not None and ans.isdigit():
            submitted = int(ans)
            if submitted == q['answer']:
                score += 1
            else:
                incorrect_answers.append({
                    "question": q['question'],
                    "correct": q['options'][q['answer']],
                    "yours": q['options'][submitted]
                })

    participant_name = session["participant_name"]
    today_str = datetime.today().strftime("%d.%m.%Y")

    return render_template(
        "results.html",
        name=participant_name,
        date_str=today_str,
        score=score,
        total=total,
        incorrect_answers=incorrect_answers
    )

@app.route("/certificate-image")
def certificate_image():
    name = request.args.get("name", "STUDENT")
    date_str = request.args.get("date", datetime.today().strftime("%d.%m.%Y"))
    download = request.args.get("download")

    data = _image_bytes(name, date_str)
    resp = make_response(data)
    resp.mimetype = "image/png"
    if download:
        resp.headers["Content-Disposition"] = f'attachment; filename="certificate_{name}.png"'
    return resp

@app.route("/certificate-pdf")
def certificate_pdf():
    name = request.args.get("name", "STUDENT")
    date_str = request.args.get("date", datetime.today().strftime("%d.%m.%Y"))

    img_data = _image_bytes(name, date_str)
    img = Image.open(BytesIO(img_data)).convert("RGB")

    buf = BytesIO()
    img.save(buf, format="PDF", resolution=300)
    pdf_bytes = buf.getvalue()

    resp = make_response(pdf_bytes)
    resp.mimetype = "application/pdf"
    resp.headers["Content-Disposition"] = f'attachment; filename="certificate_{name}.pdf"'
    return resp

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
