import { getPayload } from 'payload'
import config from './payload.config'

// Static data from locale files — used to seed CMS
const enData = {
  nav: {
    services: 'Services',
    projects: 'Projects',
    about: 'About',
    technology: 'Technology',
    contact: 'Contact',
    getInTouch: 'Get in Touch',
  },
  hero: {
    tagline: 'Next-generation technology solutions',
    headlineLine1: ['Engineering', 'the', 'Future', 'of'],
    headlineLine2: ['Intelligent', 'Solutions'],
    description:
      'We architect and deliver enterprise-grade digital products that define industries. From AI-powered platforms to scalable cloud infrastructure — built for the companies shaping tomorrow.',
    exploreSolutions: 'Explore Solutions',
    getInTouch: 'Get in Touch',
    trustedBy: 'Trusted by industry leaders',
    next: 'Next',
  },
  about: {
    label: 'About Us',
    headingLine1: "We don't just build",
    headingWord1: 'software',
    headingLine2: '— we engineer',
    headingWord2: 'futures.',
    paragraph1:
      'Innovative Solutions Tech was founded on a singular conviction: that the right technology, architected with precision and purpose, can reshape entire industries. We are a team of engineers, designers, and strategists who obsess over the details others overlook.',
    paragraph2:
      'From early-stage startups to Fortune 500 enterprises, we partner with visionary leaders to transform ambitious ideas into resilient, production-grade systems that scale — and that last. Our work spans AI, cloud infrastructure, cybersecurity, and beyond.',
    stats: [
      { target: 12, suffix: '+', label: 'Years of Excellence' },
      { target: 200, suffix: '+', label: 'Projects Delivered' },
      { target: 85, suffix: '+', label: 'Enterprise Clients' },
      { target: 99, suffix: '%', label: 'Client Retention' },
    ],
  },
  offer: {
    label: 'What We Offer',
    heading: 'Solutions built for the',
    headingAccent: 'next era',
    description:
      'We deliver end-to-end technology solutions that solve complex challenges with elegance, precision, and scale.',
  },
  services: {
    label: 'Our Services',
    heading: 'Comprehensive',
    headingAccent: 'capabilities',
    description:
      'Full-spectrum technology services, delivered with the rigor and craft that enterprise-grade systems demand.',
    learnMore: 'Learn more',
  },
  projects: {
    label: 'Featured Projects',
    heading: 'Work that',
    headingAccent: 'speaks volumes',
    description: 'A showcase of transformative projects delivered for industry leaders.',
    viewCaseStudy: 'View Case Study',
  },
  technology: {
    label: 'Technology Stack',
    heading: 'Powered by',
    headingAccent: 'modern technology',
    description:
      'We leverage the industry\'s most powerful and proven technologies to build systems that perform at scale.',
  },
  contact: {
    label: 'Get in Touch',
    heading: "Let's build something",
    headingAccent: 'extraordinary',
    description:
      'Whether you have a clear vision or need help defining the path forward, our team is ready to listen, strategize, and deliver.',
    features: [
      'Free technical consultation',
      'Response within 24 hours',
      'NDA-protected discussions',
    ],
    form: {
      name: 'Name',
      namePlaceholder: 'Your name',
      email: 'Email',
      emailPlaceholder: 'you@company.com',
      message: 'Message',
      messagePlaceholder: 'Tell us about your project...',
      send: 'Send Message',
      successTitle: 'Message sent!',
      successMessage: "We'll get back to you within 24 hours.",
    },
  },
  footer: {
    copyright: 'Innovative Solutions Tech',
    company: { about: 'About', services: 'Services', projects: 'Projects' },
    connect: { linkedin: 'LinkedIn', twitter: 'Twitter / X', github: 'GitHub' },
  },
  slides: {
    names: ['Home', 'What We Offer', 'Projects', 'About', 'Services', 'Technology', 'Contact'],
  },
}

const arData = {
  nav: {
    services: 'خدماتنا',
    projects: 'المشاريع',
    about: 'من نحن',
    technology: 'التقنيات',
    contact: 'تواصل معنا',
    getInTouch: 'تواصل معنا',
  },
  hero: {
    tagline: 'حلول تقنية من الجيل القادم',
    headlineLine1: ['نهندس', 'مستقبل', 'الحلول', ''],
    headlineLine2: ['الذكية', 'والمبتكرة'],
    description:
      'نصمم ونبني منتجات رقمية بمستوى المؤسسات تُعيد تعريف الصناعات. من منصات الذكاء الاصطناعي إلى البنية التحتية السحابية القابلة للتوسع — مصممة للشركات التي تصنع الغد.',
    exploreSolutions: 'استكشف الحلول',
    getInTouch: 'تواصل معنا',
    trustedBy: 'موثوق من قادة الصناعة',
    next: 'التالي',
  },
  about: {
    label: 'من نحن',
    headingLine1: 'نحن لا نبني فقط',
    headingWord1: 'البرمجيات',
    headingLine2: '— بل نهندس',
    headingWord2: 'المستقبل.',
    paragraph1:
      'تأسست Innovative Solutions Tech على قناعة واحدة: أن التقنية الصحيحة، المصممة بدقة وهدف، يمكنها إعادة تشكيل صناعات بأكملها. نحن فريق من المهندسين والمصممين والاستراتيجيين الذين يهتمون بأدق التفاصيل التي يغفلها الآخرون.',
    paragraph2:
      'من الشركات الناشئة إلى شركات Fortune 500، نتشارك مع القادة أصحاب الرؤية لتحويل الأفكار الطموحة إلى أنظمة إنتاجية مرنة وقابلة للتوسع — وتدوم. يمتد عملنا ليشمل الذكاء الاصطناعي، والبنية التحتية السحابية، والأمن السيبراني، وأكثر.',
    stats: [
      { target: 12, suffix: '+', label: 'سنوات من التميز' },
      { target: 200, suffix: '+', label: 'مشروع تم تسليمه' },
      { target: 85, suffix: '+', label: 'عميل مؤسسي' },
      { target: 99, suffix: '%', label: 'نسبة الاحتفاظ بالعملاء' },
    ],
  },
  offer: {
    label: 'ما نقدمه',
    heading: 'حلول مبنية لـ',
    headingAccent: 'العصر القادم',
    description: 'نقدم حلولاً تقنية شاملة تحل التحديات المعقدة بأناقة ودقة وقابلية للتوسع.',
  },
  services: {
    label: 'خدماتنا',
    heading: 'قدرات',
    headingAccent: 'شاملة',
    description: 'خدمات تقنية كاملة الطيف، تُقدَّم بالصرامة والحرفية التي تتطلبها الأنظمة المؤسسية.',
    learnMore: 'اعرف المزيد',
  },
  projects: {
    label: 'المشاريع المميزة',
    heading: 'أعمال',
    headingAccent: 'تتحدث عن نفسها',
    description: 'عرض لمشاريع تحويلية قُدِّمت لقادة الصناعة.',
    viewCaseStudy: 'عرض دراسة الحالة',
  },
  technology: {
    label: 'المنصة التقنية',
    heading: 'مدعومة بأحدث',
    headingAccent: 'التقنيات',
    description: 'نستفيد من أقوى وأثبت التقنيات في الصناعة لبناء أنظمة تعمل على نطاق واسع.',
  },
  contact: {
    label: 'تواصل معنا',
    heading: 'لنبنِ شيئاً',
    headingAccent: 'استثنائياً',
    description:
      'سواء كانت لديك رؤية واضحة أو تحتاج مساعدة في تحديد المسار، فريقنا مستعد للاستماع والتخطيط والتنفيذ.',
    features: ['استشارة تقنية مجانية', 'الرد خلال 24 ساعة', 'مناقشات محمية باتفاقية عدم إفشاء'],
    form: {
      name: 'الاسم',
      namePlaceholder: 'اسمك',
      email: 'البريد الإلكتروني',
      emailPlaceholder: 'you@company.com',
      message: 'الرسالة',
      messagePlaceholder: 'أخبرنا عن مشروعك...',
      send: 'إرسال الرسالة',
      successTitle: 'تم إرسال الرسالة!',
      successMessage: 'سنعود إليك خلال 24 ساعة.',
    },
  },
  footer: {
    copyright: 'Innovative Solutions Tech',
    company: { about: 'من نحن', services: 'خدماتنا', projects: 'المشاريع' },
    connect: { linkedin: 'لينكد إن', twitter: 'تويتر / X', github: 'جيت هب' },
  },
  slides: {
    names: ['الرئيسية', 'ما نقدمه', 'المشاريع', 'من نحن', 'الخدمات', 'التقنيات', 'تواصل معنا'],
  },
}

// Collection data
const projectsData = [
  {
    en: {
      title: 'NeuralFlow Platform',
      category: 'AI / Machine Learning',
      description:
        'Enterprise AI platform processing 50M+ predictions daily with custom transformer models and real-time inference pipelines.',
      statLabel: 'predictions/day',
    },
    ar: {
      title: 'منصة NeuralFlow',
      category: 'الذكاء الاصطناعي / التعلم الآلي',
      description:
        'منصة ذكاء اصطناعي مؤسسية تعالج أكثر من 50 مليون تنبؤ يومياً باستخدام نماذج محوّلات مخصصة وخطوط استدلال فورية.',
      statLabel: 'تنبؤ/يوم',
    },
    stat: '50M+',
    gradient: 'from-emerald-500/20 to-cyan-500/20',
    accentColor: '#00C896',
    order: 0,
  },
  {
    en: {
      title: 'CloudVault Infrastructure',
      category: 'Cloud / DevOps',
      description:
        'Multi-region cloud architecture serving 100K+ concurrent users with automated scaling and 99.99% uptime guarantee.',
      statLabel: 'uptime',
    },
    ar: {
      title: 'بنية CloudVault التحتية',
      category: 'السحابة / DevOps',
      description:
        'بنية سحابية متعددة المناطق تخدم أكثر من 100 ألف مستخدم متزامن مع توسع تلقائي وضمان وقت تشغيل 99.99%.',
      statLabel: 'وقت التشغيل',
    },
    stat: '99.99%',
    gradient: 'from-blue-500/20 to-violet-500/20',
    accentColor: '#2563EB',
    order: 1,
  },
  {
    en: {
      title: 'SecureEdge Framework',
      category: 'Cybersecurity',
      description:
        'Zero-trust security framework protecting $2B+ in digital assets with real-time threat detection and response.',
      statLabel: 'assets protected',
    },
    ar: {
      title: 'إطار SecureEdge',
      category: 'الأمن السيبراني',
      description:
        'إطار أمني بنموذج الثقة المعدومة يحمي أصولاً رقمية بقيمة تتجاوز 2 مليار دولار مع كشف واستجابة للتهديدات في الوقت الفعلي.',
      statLabel: 'أصول محمية',
    },
    stat: '$2B+',
    gradient: 'from-violet-500/20 to-pink-500/20',
    accentColor: '#7C3AED',
    order: 2,
  },
  {
    en: {
      title: 'DataPulse Analytics',
      category: 'Data / Analytics',
      description:
        'Real-time analytics engine processing 1TB+ daily data streams with sub-second query performance and predictive insights.',
      statLabel: 'daily data',
    },
    ar: {
      title: 'تحليلات DataPulse',
      category: 'البيانات / التحليلات',
      description:
        'محرك تحليلات فوري يعالج أكثر من 1 تيرابايت من تدفقات البيانات اليومية بأداء استعلام أقل من ثانية ورؤى تنبؤية.',
      statLabel: 'بيانات يومية',
    },
    stat: '1TB+',
    gradient: 'from-amber-500/20 to-orange-500/20',
    accentColor: '#F59E0B',
    order: 3,
  },
]

const offeringsData = [
  {
    en: { title: 'AI & Machine Learning', description: 'Custom AI models, NLP engines, and intelligent automation that transform raw data into strategic advantage.' },
    ar: { title: 'الذكاء الاصطناعي والتعلم الآلي', description: 'نماذج ذكاء اصطناعي مخصصة، ومحركات معالجة اللغة الطبيعية، وأتمتة ذكية تحوّل البيانات الخام إلى ميزة استراتيجية.' },
    icon: 'brain',
    accentColor: '#00C896',
    order: 0,
  },
  {
    en: { title: 'Cloud Architecture', description: 'Scalable, resilient cloud infrastructure on AWS, GCP, and Azure — engineered for 99.99% uptime.' },
    ar: { title: 'البنية السحابية', description: 'بنية تحتية سحابية قابلة للتوسع ومرنة على AWS وGCP وAzure — مصممة لوقت تشغيل 99.99%.' },
    icon: 'cloud',
    accentColor: '#2563EB',
    order: 1,
  },
  {
    en: { title: 'Cybersecurity', description: 'Enterprise-grade security frameworks, penetration testing, and zero-trust architecture implementation.' },
    ar: { title: 'الأمن السيبراني', description: 'أطر أمنية بمستوى المؤسسات، واختبار الاختراق، وتنفيذ معمارية الثقة المعدومة.' },
    icon: 'shield',
    accentColor: '#7C3AED',
    order: 2,
  },
  {
    en: { title: 'Performance Engineering', description: 'Sub-second load times, optimized APIs, and real-time data pipelines built for scale.' },
    ar: { title: 'هندسة الأداء', description: 'أوقات تحميل أقل من ثانية، وواجهات برمجة محسّنة، وخطوط أنابيب بيانات فورية مبنية للتوسع.' },
    icon: 'zap',
    accentColor: '#F59E0B',
    order: 3,
  },
  {
    en: { title: 'Web & Mobile Platforms', description: 'Full-stack digital products with pixel-perfect interfaces and seamless cross-platform experiences.' },
    ar: { title: 'منصات الويب والجوال', description: 'منتجات رقمية متكاملة بواجهات مثالية وتجارب سلسة عبر جميع المنصات.' },
    icon: 'globe',
    accentColor: '#EC4899',
    order: 4,
  },
  {
    en: { title: 'Data Analytics', description: 'Real-time dashboards, predictive analytics, and business intelligence solutions that drive decisions.' },
    ar: { title: 'تحليل البيانات', description: 'لوحات تحكم فورية، وتحليلات تنبؤية، وحلول ذكاء الأعمال التي تقود القرارات.' },
    icon: 'barChart3',
    accentColor: '#06B6D4',
    order: 5,
  },
]

const servicesData = [
  {
    en: {
      title: 'Artificial Intelligence & ML',
      overview:
        'We design and deploy production-grade AI systems — from custom LLMs and computer vision to recommendation engines and autonomous agents. Our models are built for accuracy, speed, and real-world reliability.',
    },
    ar: {
      title: 'الذكاء الاصطناعي والتعلم الآلي',
      overview:
        'نصمم وننشر أنظمة ذكاء اصطناعي جاهزة للإنتاج — من نماذج اللغة الكبيرة المخصصة والرؤية الحاسوبية إلى محركات التوصية والوكلاء المستقلين. نماذجنا مبنية للدقة والسرعة والموثوقية الواقعية.',
    },
    technologies: ['PyTorch', 'TensorFlow', 'LangChain', 'OpenAI', 'Hugging Face', 'MLflow'],
    accentColor: '#00C896',
    order: 0,
  },
  {
    en: {
      title: 'Cloud & Infrastructure',
      overview:
        'We architect multi-cloud environments optimized for cost, performance, and resilience. From Kubernetes orchestration to serverless computing, we build infrastructure that scales with your ambition.',
    },
    ar: {
      title: 'السحابة والبنية التحتية',
      overview:
        'نصمم بيئات سحابية متعددة محسّنة للتكلفة والأداء والمرونة. من تنسيق Kubernetes إلى الحوسبة بدون خوادم، نبني بنية تحتية تتوسع مع طموحاتك.',
    },
    technologies: ['AWS', 'GCP', 'Azure', 'Kubernetes', 'Terraform', 'Docker'],
    accentColor: '#2563EB',
    order: 1,
  },
  {
    en: {
      title: 'Product Engineering',
      overview:
        'End-to-end product development from ideation to launch. We build web and mobile applications with obsessive attention to performance, accessibility, and user experience.',
    },
    ar: {
      title: 'هندسة المنتجات',
      overview:
        'تطوير شامل للمنتجات من الفكرة إلى الإطلاق. نبني تطبيقات الويب والجوال مع اهتمام شديد بالأداء وسهولة الوصول وتجربة المستخدم.',
    },
    technologies: ['React', 'Next.js', 'React Native', 'Node.js', 'PostgreSQL', 'GraphQL'],
    accentColor: '#7C3AED',
    order: 2,
  },
  {
    en: {
      title: 'Security & Compliance',
      overview:
        'Enterprise security audits, penetration testing, and compliance frameworks. We implement zero-trust architectures and ensure your systems meet SOC 2, HIPAA, and GDPR standards.',
    },
    ar: {
      title: 'الأمن والامتثال',
      overview:
        'تدقيقات أمنية مؤسسية، واختبار الاختراق، وأطر الامتثال. ننفذ معماريات الثقة المعدومة ونضمن أن أنظمتك تلبي معايير SOC 2 وHIPAA وGDPR.',
    },
    technologies: ['Zero Trust', 'SOC 2', 'HIPAA', 'Vault', 'WAF', 'SIEM'],
    accentColor: '#F59E0B',
    order: 3,
  },
  {
    en: {
      title: 'Data Engineering & Analytics',
      overview:
        'We build modern data stacks — real-time pipelines, data lakes, and analytics platforms that turn your data into your most powerful competitive advantage.',
    },
    ar: {
      title: 'هندسة البيانات والتحليلات',
      overview:
        'نبني مكدسات بيانات حديثة — خطوط أنابيب فورية، وبحيرات بيانات، ومنصات تحليلات تحوّل بياناتك إلى أقوى ميزة تنافسية لديك.',
    },
    technologies: ['Spark', 'Kafka', 'Snowflake', 'dbt', 'Airflow', 'Looker'],
    accentColor: '#EC4899',
    order: 4,
  },
]

const technologiesData = [
  // Row 1
  { name: 'React', color: '#61DAFB', row: '1', order: 0 },
  { name: 'Next.js', color: '#888888', row: '1', order: 1 },
  { name: 'TypeScript', color: '#3178C6', row: '1', order: 2 },
  { name: 'Node.js', color: '#339933', row: '1', order: 3 },
  { name: 'Python', color: '#3776AB', row: '1', order: 4 },
  { name: 'PostgreSQL', color: '#4169E1', row: '1', order: 5 },
  { name: 'Kubernetes', color: '#326CE5', row: '1', order: 6 },
  { name: 'Docker', color: '#2496ED', row: '1', order: 7 },
  // Row 2
  { name: 'AWS', color: '#FF9900', row: '2', order: 0 },
  { name: 'Terraform', color: '#7B42BC', row: '2', order: 1 },
  { name: 'GraphQL', color: '#E10098', row: '2', order: 2 },
  { name: 'Redis', color: '#DC382D', row: '2', order: 3 },
  { name: 'TensorFlow', color: '#FF6F00', row: '2', order: 4 },
  { name: 'PyTorch', color: '#EE4C2C', row: '2', order: 5 },
  { name: 'Kafka', color: '#888888', row: '2', order: 6 },
  { name: 'Go', color: '#00ADD8', row: '2', order: 7 },
  // Row 3
  { name: 'Rust', color: '#CE412B', row: '3', order: 0 },
  { name: 'Swift', color: '#F05138', row: '3', order: 1 },
  { name: 'MongoDB', color: '#47A248', row: '3', order: 2 },
  { name: 'Snowflake', color: '#29B5E8', row: '3', order: 3 },
  { name: 'OpenAI', color: '#00A67E', row: '3', order: 4 },
  { name: 'Figma', color: '#F24E1E', row: '3', order: 5 },
  { name: 'Vercel', color: '#888888', row: '3', order: 6 },
  { name: 'GitHub', color: '#888888', row: '3', order: 7 },
]

async function seed() {
  const payload = await getPayload({ config })

  console.log('Seeding database...')

  // 1. Create admin user
  try {
    await payload.create({
      collection: 'users',
      data: {
        email: 'admin@inst.com',
        password: 'changeme123',
      },
    })
    console.log('Created admin user: admin@inst.com / changeme123')
  } catch {
    console.log('Admin user may already exist, skipping...')
  }

  // 2. Seed SiteContent global (EN)
  console.log('Seeding SiteContent (EN)...')
  await payload.updateGlobal({
    slug: 'site-content',
    locale: 'en',
    data: {
      nav: enData.nav,
      hero: {
        tagline: enData.hero.tagline,
        headlineLine1: enData.hero.headlineLine1.filter(Boolean).map((word) => ({ word })),
        headlineLine2: enData.hero.headlineLine2.map((word) => ({ word })),
        description: enData.hero.description,
        exploreSolutions: enData.hero.exploreSolutions,
        getInTouch: enData.hero.getInTouch,
        trustedBy: enData.hero.trustedBy,
        next: enData.hero.next,
      },
      about: {
        label: enData.about.label,
        headingLine1: enData.about.headingLine1,
        headingWord1: enData.about.headingWord1,
        headingLine2: enData.about.headingLine2,
        headingWord2: enData.about.headingWord2,
        paragraph1: enData.about.paragraph1,
        paragraph2: enData.about.paragraph2,
        stats: enData.about.stats,
      },
      offer: enData.offer,
      services: enData.services,
      projects: enData.projects,
      technology: enData.technology,
      contact: {
        ...enData.contact,
        features: enData.contact.features.map((text) => ({ text })),
      },
      footer: enData.footer,
      slides: {
        names: enData.slides.names.map((name) => ({ name })),
      },
    },
  })

  // 3. Seed SiteContent global (AR)
  console.log('Seeding SiteContent (AR)...')
  await payload.updateGlobal({
    slug: 'site-content',
    locale: 'ar',
    data: {
      nav: arData.nav,
      hero: {
        tagline: arData.hero.tagline,
        headlineLine1: arData.hero.headlineLine1.filter(Boolean).map((word) => ({ word })),
        headlineLine2: arData.hero.headlineLine2.map((word) => ({ word })),
        description: arData.hero.description,
        exploreSolutions: arData.hero.exploreSolutions,
        getInTouch: arData.hero.getInTouch,
        trustedBy: arData.hero.trustedBy,
        next: arData.hero.next,
      },
      about: {
        label: arData.about.label,
        headingLine1: arData.about.headingLine1,
        headingWord1: arData.about.headingWord1,
        headingLine2: arData.about.headingLine2,
        headingWord2: arData.about.headingWord2,
        paragraph1: arData.about.paragraph1,
        paragraph2: arData.about.paragraph2,
        stats: arData.about.stats,
      },
      offer: arData.offer,
      services: arData.services,
      projects: arData.projects,
      technology: arData.technology,
      contact: {
        ...arData.contact,
        features: arData.contact.features.map((text) => ({ text })),
      },
      footer: arData.footer,
      slides: {
        names: arData.slides.names.map((name) => ({ name })),
      },
    },
  })

  // 4. Seed Projects
  console.log('Seeding Projects...')
  for (const project of projectsData) {
    const doc = await payload.create({
      collection: 'projects',
      locale: 'en',
      data: {
        title: project.en.title,
        category: project.en.category,
        description: project.en.description,
        statLabel: project.en.statLabel,
        stat: project.stat,
        gradient: project.gradient,
        accentColor: project.accentColor,
        order: project.order,
      },
    })
    await payload.update({
      collection: 'projects',
      id: doc.id,
      locale: 'ar',
      data: {
        title: project.ar.title,
        category: project.ar.category,
        description: project.ar.description,
        statLabel: project.ar.statLabel,
      },
    })
  }

  // 5. Seed Offerings
  console.log('Seeding Offerings...')
  for (const offering of offeringsData) {
    const doc = await payload.create({
      collection: 'offerings',
      locale: 'en',
      data: {
        title: offering.en.title,
        description: offering.en.description,
        icon: offering.icon,
        accentColor: offering.accentColor,
        order: offering.order,
      },
    })
    await payload.update({
      collection: 'offerings',
      id: doc.id,
      locale: 'ar',
      data: {
        title: offering.ar.title,
        description: offering.ar.description,
      },
    })
  }

  // 6. Seed Services
  console.log('Seeding Services...')
  for (const service of servicesData) {
    const doc = await payload.create({
      collection: 'services',
      locale: 'en',
      data: {
        title: service.en.title,
        overview: service.en.overview,
        technologies: service.technologies.map((name) => ({ name })),
        accentColor: service.accentColor,
        order: service.order,
      },
    })
    await payload.update({
      collection: 'services',
      id: doc.id,
      locale: 'ar',
      data: {
        title: service.ar.title,
        overview: service.ar.overview,
      },
    })
  }

  // 7. Seed Technologies
  console.log('Seeding Technologies...')
  for (const tech of technologiesData) {
    await payload.create({
      collection: 'technologies',
      data: {
        name: tech.name,
        color: tech.color,
        row: tech.row,
        order: tech.order,
      },
    })
  }

  console.log('Seeding complete!')
  process.exit(0)
}

seed().catch((err) => {
  console.error('Seed failed:', err)
  process.exit(1)
})
