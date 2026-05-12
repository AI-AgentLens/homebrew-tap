cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.962"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.962/agentshield_0.2.962_darwin_amd64.tar.gz"
      sha256 "651582cf165176494b456aa19e36ac76ef150692fce362a0e36b48f9fb88e236"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.962/agentshield_0.2.962_darwin_arm64.tar.gz"
      sha256 "5564b8875b50adca630bd7b509d1d2cd8af9c6cbb69d10a4f7b01a7b4ee62f68"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.962/agentshield_0.2.962_linux_amd64.tar.gz"
      sha256 "94d6a4862c3b8c5eb693cad242a622f0d6ba9cace7478dff3096118d46fa561f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.962/agentshield_0.2.962_linux_arm64.tar.gz"
      sha256 "1f00db8e704cc7ad598ae7fc18203a335383bad610181eea1c8618287d59b98b"
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
