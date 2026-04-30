cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.834"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.834/agentshield_0.2.834_darwin_amd64.tar.gz"
      sha256 "52b417214659b82713f2d659c723c34941701235ec1111100cc2ca0573a8536d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.834/agentshield_0.2.834_darwin_arm64.tar.gz"
      sha256 "b675b104120b47a91aa44f1831d30e59b931d0271c03364947c8cf0cf7510940"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.834/agentshield_0.2.834_linux_amd64.tar.gz"
      sha256 "73b1725d6666495229be1e8f76935caa520301dc6b70f3573d0489f6ab7810ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.834/agentshield_0.2.834_linux_arm64.tar.gz"
      sha256 "59145cee05e0463cf3ac7acda39b40c2076b1380ffcb901e33ccadb16bfd60aa"
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
