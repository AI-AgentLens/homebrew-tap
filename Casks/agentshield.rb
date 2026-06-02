cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1191"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1191/agentshield_0.2.1191_darwin_amd64.tar.gz"
      sha256 "a8dc847afb0ce9fda7b3b776222e1b530f9c32cfe227e89bc8b55557b0866c59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1191/agentshield_0.2.1191_darwin_arm64.tar.gz"
      sha256 "ea27b5733dc5ea365b07ef477d891ea0e429220244ff20e33c1c457c1d1cc52b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1191/agentshield_0.2.1191_linux_amd64.tar.gz"
      sha256 "8588d6f037f1a30bf0d159585b24507f33c80959e560a9ad9cde99b314644d9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1191/agentshield_0.2.1191_linux_arm64.tar.gz"
      sha256 "38841e3fdf2ffd9bd41348a9ebe7e8d8fa382097b1df2b8ceadd6981ebb4a967"
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
