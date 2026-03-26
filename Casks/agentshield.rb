cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.23"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.23/agentshield_0.2.23_darwin_amd64.tar.gz"
      sha256 "70ff82c3a6495498874f0d1a35a3c11e635781d3cd6c9c9f8ec21f883c210ff6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.23/agentshield_0.2.23_darwin_arm64.tar.gz"
      sha256 "1029778bb450b2097efb0a5090d86d7c24da0674bf867eedbc864ad11b77fe43"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.23/agentshield_0.2.23_linux_amd64.tar.gz"
      sha256 "23561e94fb13d1da05bf3a1e127260aa73e277be81b2cf8f250269926abb4f28"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.23/agentshield_0.2.23_linux_arm64.tar.gz"
      sha256 "52009a63cec66c2ce86a495764042a27759594c1a1fa6fcaea48c951bff4c752"
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
