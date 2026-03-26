cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.78"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.78/agentshield_0.2.78_darwin_amd64.tar.gz"
      sha256 "e4cd53986a00e1255c15a4b9928a55afe222d4f0af64754740ad69ae4e403ce0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.78/agentshield_0.2.78_darwin_arm64.tar.gz"
      sha256 "e5f4b5b8319c16f6299fccbfc7022bae321725f9dd44015ef30f2bd70bbda55b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.78/agentshield_0.2.78_linux_amd64.tar.gz"
      sha256 "f3668106cdd3b255f68d068f603ccccf73bfcaec02258267a2607ee9a6227cff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.78/agentshield_0.2.78_linux_arm64.tar.gz"
      sha256 "97951a0a340ca65c0fe92d5be9b3761c976b0b83b37f8c6ba731e6f0527a600c"
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
