cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.745"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.745/agentshield_0.2.745_darwin_amd64.tar.gz"
      sha256 "4657fc5d5a429cb23f46697fe3e8d354c697681819b85ee6b7a9712a45ff20f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.745/agentshield_0.2.745_darwin_arm64.tar.gz"
      sha256 "07861e3037f0c723fc9378fbc935e41b92a9355fba3c08efd800d9adfcd47746"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.745/agentshield_0.2.745_linux_amd64.tar.gz"
      sha256 "51fb76b51412a7f6931aaa5b4acdc2ac47d2df988c9c3f1d48f540d75cd44ba1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.745/agentshield_0.2.745_linux_arm64.tar.gz"
      sha256 "5671dde23543db148c32bb77ab4cc787a87953e535d05004d3d35c89412226f9"
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
