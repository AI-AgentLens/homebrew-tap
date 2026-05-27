cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1127"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1127/agentshield_0.2.1127_darwin_amd64.tar.gz"
      sha256 "2364ab92036365b0eff5bbd4cdb16fd95c55acea744fd11e753786d4279cb7f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1127/agentshield_0.2.1127_darwin_arm64.tar.gz"
      sha256 "63923cbfb813c3e049c49111251f3fb6ea342c4e3ad330b097bd992827d6a578"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1127/agentshield_0.2.1127_linux_amd64.tar.gz"
      sha256 "a4d50d4fa44ede33a8bba8e03c3a09b33ac3e0808d8708482a62dbb6566a0a42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1127/agentshield_0.2.1127_linux_arm64.tar.gz"
      sha256 "01f2d8cbefbc09deb5e49ea4300001124c27d43d2b61c427b7dc2888ae758937"
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
