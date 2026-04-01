cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.277"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.277/agentshield_0.2.277_darwin_amd64.tar.gz"
      sha256 "0602c26ca15c112ea592fd9d2ba6f99ac3c75295b587d7314e54e976413ce4b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.277/agentshield_0.2.277_darwin_arm64.tar.gz"
      sha256 "7e4ff51b6f5e5b7bd5efa96fa3f4c6d84fbdd8bf027f707a6a0a4eb7a33a9ff2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.277/agentshield_0.2.277_linux_amd64.tar.gz"
      sha256 "edae8b962f8b1cc42a560c5b784751ee43746747e0263a86c722cbfc8282d234"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.277/agentshield_0.2.277_linux_arm64.tar.gz"
      sha256 "9774eed11a2befba98d19cf5e0604282b131ebeab7b445cd2b1faef1b6cdfb66"
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
