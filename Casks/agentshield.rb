cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1159"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1159/agentshield_0.2.1159_darwin_amd64.tar.gz"
      sha256 "8df36ca9ad174eb2755a70c100c297ed5e20085ba01922f8c0771c428e6b7822"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1159/agentshield_0.2.1159_darwin_arm64.tar.gz"
      sha256 "5d7899e389a6d802c7ef77014b475e99078d7d3cbb20094961e4b1c0ab750678"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1159/agentshield_0.2.1159_linux_amd64.tar.gz"
      sha256 "79348552670036f5fb4f069bd2c98cc5ce21f69f7743163e6c5967e8ae474f10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1159/agentshield_0.2.1159_linux_arm64.tar.gz"
      sha256 "2b581c04b34fd1a6f513a8cb8af78899a38aadd502db6018d2ffb69e6421aea3"
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
