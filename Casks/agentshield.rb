cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2335"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2335/agentshield_0.2.2335_darwin_amd64.tar.gz"
      sha256 "932a7d088f11b6e0045cc3432b64fe27630c621f105a540066b110a2015213bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2335/agentshield_0.2.2335_darwin_arm64.tar.gz"
      sha256 "a9bd6a8385d15ccefe14e6b0f1c959f5af057e156ba8737ee0e4da468d30e360"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2335/agentshield_0.2.2335_linux_amd64.tar.gz"
      sha256 "b9973c767214cf632f9785cc70729d830c2bbf4c2ff000a812737961a7fe4836"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2335/agentshield_0.2.2335_linux_arm64.tar.gz"
      sha256 "91f435c899c7e46af60c645318641d09235de8e4346ca5ef7677eefcb0c98cad"
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
