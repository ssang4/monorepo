function HomePage() {
  return (
    <>
      <div className="bg-slate-800 text-slate-100 font-sans">
        <div className="container mx-auto px-4 min-h-screen flex flex-col justify-center">
          <div className="mb-2">
            <h2 className="text-xl">Shiuh Sen Ang</h2>
            <h1 className="text-4xl font-mono font-bold">Platform / Devops Engineer</h1>
          </div>
          <div className="mb-8">
            <p>Senior platform engineer at <a href="https://www.zalando.com" target="_blank">Zalando</a>/<a href="https://www.tradebyte.com" target="_blank">Tradebyte</a>. Currently based in Europe/Germany.</p>
          </div>
          <div>
            <p className="text-sm">Email: <a href="mailto:ssang@protonmail.com" className="text-rose-500 underline">ssang@protonmail.com</a></p>
            <p className="text-sm">Linkedin: <a href="https://www.linkedin.com/in/shiuh-sen-ang" target="_blank" className="text-rose-500 underline">shiuh-sen-ang</a></p>
            <p className="text-sm">Github: <a href="https://github.com/ssang4" target="_blank" className="text-rose-500 underline">ssang4</a></p>
          </div>
        </div>
      </div>
    </>
  )
}

export default HomePage