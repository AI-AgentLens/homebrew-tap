cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.47"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.47/agentshield_0.2.47_darwin_amd64.tar.gz"
      sha256 "295f3691d92712cf41eca1717d1b37d77b81c013c529b45cc4cc26f206468a43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.47/agentshield_0.2.47_darwin_arm64.tar.gz"
      sha256 "177ec668525075d13541565ab0eac196767f7bb4b401ff42ce3d6a5cf3339fb9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.47/agentshield_0.2.47_linux_amd64.tar.gz"
      sha256 "93ee7e138e77a7597a45338ad09e51c770ed04e38a8ef18a40e3fa80a73a32c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.47/agentshield_0.2.47_linux_arm64.tar.gz"
      sha256 "36c1c80dd0d61b8ceb90d3dc363c7085b474baf138b09846ba05dace6e5a82ed"
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
