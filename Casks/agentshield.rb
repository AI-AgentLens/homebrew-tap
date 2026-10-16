cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2449"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2449/agentshield_0.2.2449_darwin_amd64.tar.gz"
      sha256 "db15111f73d8489b4af6db4ceb2709307ac587a14f133aab65ff4ad4dbcffdd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2449/agentshield_0.2.2449_darwin_arm64.tar.gz"
      sha256 "cdf4f18201d989f32437e03e13ef440d456a291fe1ebee9cbd324b224305644e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2449/agentshield_0.2.2449_linux_amd64.tar.gz"
      sha256 "cae29b9dc507db7662f80e3ec5af1903944176d76e343503ab9121fbd6a5a954"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2449/agentshield_0.2.2449_linux_arm64.tar.gz"
      sha256 "4a5b62d6cb7b780262d3112801644e5ff6c9e4aee67950513f288bbb45ff6a3d"
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
