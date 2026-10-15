cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2436"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2436/agentshield_0.2.2436_darwin_amd64.tar.gz"
      sha256 "2d4a79503e4a7e3e20b0e69d164f58887bf21d4665433639c1d2780b0da1aca9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2436/agentshield_0.2.2436_darwin_arm64.tar.gz"
      sha256 "62a0d7561a8d7e8b53f258cde94dc1b08fe8eaaeaef49e990904fa3af1c3e438"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2436/agentshield_0.2.2436_linux_amd64.tar.gz"
      sha256 "427da51cfd491616dbacd83c0df81a87a51c806b38ef1740f920ce5678aa66c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2436/agentshield_0.2.2436_linux_arm64.tar.gz"
      sha256 "d48c3afafccff2021bcf5b0c539a12404e21b965e0df9b9500aefea889fa5317"
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
