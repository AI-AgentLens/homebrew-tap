cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.197"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.197/agentshield_0.2.197_darwin_amd64.tar.gz"
      sha256 "5b7271baaf02a90536b0bfdfe580a372e2033a0031a2b3dcc991c3ce52fca930"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.197/agentshield_0.2.197_darwin_arm64.tar.gz"
      sha256 "4db021049afc2bc3a91517cd6b204687188419ba99c552a475b279d9ccc9cd2d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.197/agentshield_0.2.197_linux_amd64.tar.gz"
      sha256 "9d0f23f1228957e5fb74ef21002c9b13c5cb4f910b0a4598a257c14243029456"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.197/agentshield_0.2.197_linux_arm64.tar.gz"
      sha256 "2332ec1d8151f1078ab413021990caa628c27a0048b30522d6ec817455e40e0e"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
