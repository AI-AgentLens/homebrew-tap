cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.31"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.31/agentshield_0.2.31_darwin_amd64.tar.gz"
      sha256 "8a938d6aa51a9160225345fec0b2aacf58c836733544cf47c1924fa1b92ea4f8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.31/agentshield_0.2.31_darwin_arm64.tar.gz"
      sha256 "3686d1bfa59cad13c9746fd02c57685cf877003a43c06b7e535b78758bb43352"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.31/agentshield_0.2.31_linux_amd64.tar.gz"
      sha256 "8f43aaf038a072139ff2df34e67b9e438a5322fa9f7ceb8231e7081ca56ef2b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.31/agentshield_0.2.31_linux_arm64.tar.gz"
      sha256 "335c04ee42b424b1be2b29ecd15f9daef630f4c2561680f451422bea9b2a007d"
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
