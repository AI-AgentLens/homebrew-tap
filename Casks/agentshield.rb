cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2107"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2107/agentshield_0.2.2107_darwin_amd64.tar.gz"
      sha256 "d8983525a80b0325ee02b0f26a4aa40c5e99b64520e0938ca7af929143f98a6b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2107/agentshield_0.2.2107_darwin_arm64.tar.gz"
      sha256 "603604861956241a5cf47140ec73a4bd79719c7a419cb948c5ebead25a837334"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2107/agentshield_0.2.2107_linux_amd64.tar.gz"
      sha256 "c2fa4189f665f27741cb025acca98fe265b34806e59c87654b5965a1e1c1a4fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2107/agentshield_0.2.2107_linux_arm64.tar.gz"
      sha256 "1c36cb8b3a3668521ce2240d9164aa99128b2a5b70ccaaaf720ddf45f47236a0"
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
