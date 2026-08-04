cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1781"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1781/agentshield_0.2.1781_darwin_amd64.tar.gz"
      sha256 "596fabf394eb0ef070644fa2ee43a9a7420e5a9d42a7365c5151743c31e50a0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1781/agentshield_0.2.1781_darwin_arm64.tar.gz"
      sha256 "a5c73a1f73d6ef01d3a0c2932abcd2e70f322d7b7a22a36e7b69197764f3fcb8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1781/agentshield_0.2.1781_linux_amd64.tar.gz"
      sha256 "433d71c1c736c03c8f5aabf61a9264f0b97cdee4f70e6b9e7f9bf0d51031d3e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1781/agentshield_0.2.1781_linux_arm64.tar.gz"
      sha256 "35b27b705b280028f79317f0404f57124497252d152086cf736561e5dd7b811c"
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
