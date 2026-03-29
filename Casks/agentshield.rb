cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.218"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.218/agentshield_0.2.218_darwin_amd64.tar.gz"
      sha256 "c59b386790e52875da71952fd0388a85b567eb55c97ef6b5fbd0d596c6eab1be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.218/agentshield_0.2.218_darwin_arm64.tar.gz"
      sha256 "646fc03ed2a4c797a1174aa04422410ab7bc8f41d5c6fc8f3c755967e3cfd472"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.218/agentshield_0.2.218_linux_amd64.tar.gz"
      sha256 "2fd1642aada142a5df281c02d259d9c5f00b807e0944a7d288f9f8abd9bd24a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.218/agentshield_0.2.218_linux_arm64.tar.gz"
      sha256 "28a50298f6bbbbd8fa2dc62c3f956b86e048898b916dcd5148b86f56d08508a4"
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
