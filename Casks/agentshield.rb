cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.440"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.440/agentshield_0.2.440_darwin_amd64.tar.gz"
      sha256 "ce798055f9754d0f23ba503aa803e02fe98e07eea10f0bc0d4b8169ba19ea26f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.440/agentshield_0.2.440_darwin_arm64.tar.gz"
      sha256 "233e56463ef27f3fb3134952a275488603804aaeb898c06a4b832c6fb282228b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.440/agentshield_0.2.440_linux_amd64.tar.gz"
      sha256 "c829f973a091d32c2b0db8989dac6e87ae76e89fb447296364ac92c67d38bdfc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.440/agentshield_0.2.440_linux_arm64.tar.gz"
      sha256 "4e60d35837d0101748186f6cc15f7666331b3cf240f68f8a7afb89e41046b452"
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
