cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.984"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.984/agentshield_0.2.984_darwin_amd64.tar.gz"
      sha256 "d03e87c0f4f811520c97208fe558d730ba18658e77ea3cb6399db4943e4a7de8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.984/agentshield_0.2.984_darwin_arm64.tar.gz"
      sha256 "51d7df7f848f1660860a46b3feb6b32576b29098c8a7e80a64354bbade33b973"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.984/agentshield_0.2.984_linux_amd64.tar.gz"
      sha256 "bf224a73e333db8cdf4e1605636022bb71e237f4ddbc95052e3f4be1b6cbef5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.984/agentshield_0.2.984_linux_arm64.tar.gz"
      sha256 "919c08aa780479291d4347ce21a914edd8a5c9733c8b0350df6a97da02aec897"
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
