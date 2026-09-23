cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2228"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2228/agentshield_0.2.2228_darwin_amd64.tar.gz"
      sha256 "eacbf140094e20d8d3f3367402e593c393651b69f8884373a741b2cc56ff43d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2228/agentshield_0.2.2228_darwin_arm64.tar.gz"
      sha256 "282b4c9778dc1ce20b157a829b8362cbee36b282191259139f5c950798b42a12"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2228/agentshield_0.2.2228_linux_amd64.tar.gz"
      sha256 "5f2094459ccd646b601018798edac87813f683d0ac44c35f641b014c9ab286b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2228/agentshield_0.2.2228_linux_arm64.tar.gz"
      sha256 "298f873fba0bce35d54282df4459784e24a1053cbdb5ddeb51dc84da6c93d44e"
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
