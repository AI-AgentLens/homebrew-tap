cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1254"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1254/agentshield_0.2.1254_darwin_amd64.tar.gz"
      sha256 "f548ff32c1b7c67a0f6f3136e8cad060a54cbc0aed8503c2b20950f57db62561"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1254/agentshield_0.2.1254_darwin_arm64.tar.gz"
      sha256 "c2396a549e8fcd900ad46f009f69e8236f5b3752ad339633330310e0e82e51d9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1254/agentshield_0.2.1254_linux_amd64.tar.gz"
      sha256 "e77a36cf5536a46b65d706e96c34c85f132a3df4e20f525255157f2e687e020f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1254/agentshield_0.2.1254_linux_arm64.tar.gz"
      sha256 "bc7664efdc0b3c01970910833626eb7f48944422a5007bcb1432a00500d4ae3e"
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
