cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.38"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.38/agentshield_0.2.38_darwin_amd64.tar.gz"
      sha256 "71a17c193807def1fa011b8a8dee35a6e8e7840dcced76e4cc60f35bf5ce744c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.38/agentshield_0.2.38_darwin_arm64.tar.gz"
      sha256 "1f7e155dafaeae131c35dc282a5dbdf9e75ff1d97528cadd39f409e52e5edac3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.38/agentshield_0.2.38_linux_amd64.tar.gz"
      sha256 "8f9037b8c120758142c776453f36b7514e1f60fa1747eb454c255269c6739049"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.38/agentshield_0.2.38_linux_arm64.tar.gz"
      sha256 "e24033337521936a88a787315bf5b4a51197c454bde56822754cf59ef1764f07"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
