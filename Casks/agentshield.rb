cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1771"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1771/agentshield_0.2.1771_darwin_amd64.tar.gz"
      sha256 "00321fdfd5946d19f3fab993a9c075eb1b120b0ea878ae9c80ee9ada2e2afebd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1771/agentshield_0.2.1771_darwin_arm64.tar.gz"
      sha256 "d26e80353342e674546ec47459ae9504fe2a7f83b85416c3cae6b9087d61f476"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1771/agentshield_0.2.1771_linux_amd64.tar.gz"
      sha256 "4bda60b3e9cbb6291afab00b4329cb0b998b491fcd4230af6c73ef9463fecf52"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1771/agentshield_0.2.1771_linux_arm64.tar.gz"
      sha256 "e801e8a7212bc7f9c153d9d3ab9a127fee157ff80179bcaf15fa9f4770b9f59a"
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
