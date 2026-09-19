cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2187"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2187/agentshield_0.2.2187_darwin_amd64.tar.gz"
      sha256 "5fb6fab0725d755d0e52427f10a64b6d5d5e07e6861cff5f8c1b367c353927c6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2187/agentshield_0.2.2187_darwin_arm64.tar.gz"
      sha256 "d1d579b4e77efe6edb08ac42b92820b356ae98f9cbe7e204a3b312f158fb2aa2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2187/agentshield_0.2.2187_linux_amd64.tar.gz"
      sha256 "e1b94256872a1f0c875364472dde3aff87ba3c2095d2d0cb795007f21493e1d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2187/agentshield_0.2.2187_linux_arm64.tar.gz"
      sha256 "c0fa03a1640ef29b0c3d2c30d1020e6540a699ec52dd1b6d6fcc94435f84f571"
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
