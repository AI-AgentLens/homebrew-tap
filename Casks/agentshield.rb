cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1802"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1802/agentshield_0.2.1802_darwin_amd64.tar.gz"
      sha256 "20768fc598989885a79d3c3a209af249575b45675430d2feb1b0976a2ee721c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1802/agentshield_0.2.1802_darwin_arm64.tar.gz"
      sha256 "8ab38e1661ea929dc7fdd845f663c508b184b27272e87b010fbf1fd238adeedc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1802/agentshield_0.2.1802_linux_amd64.tar.gz"
      sha256 "9b20ae43ce867189be15595e4fbf63fbf4821bf2978152c70e8cff84aa451a43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1802/agentshield_0.2.1802_linux_arm64.tar.gz"
      sha256 "fce47c857710b90298220273e0d34038c575e0a7040325d31c07fabcb90e29ed"
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
