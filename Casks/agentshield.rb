cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2235"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2235/agentshield_0.2.2235_darwin_amd64.tar.gz"
      sha256 "2c11609b68972f683797df8ac8d19ff4d6f1f853f8e7167405efafac8c8741e0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2235/agentshield_0.2.2235_darwin_arm64.tar.gz"
      sha256 "b10e2ba030ef181328540b87ae552f0abb76f2a3b04c25b52712ce2a863b06f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2235/agentshield_0.2.2235_linux_amd64.tar.gz"
      sha256 "878c4440c13cafc8098bab2cc7511308b8434c20bdb37967be0e1f1570aec70d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2235/agentshield_0.2.2235_linux_arm64.tar.gz"
      sha256 "4739ae75022a09d35b5bb286ff3dd40be3197f18b04c5dbf45762aee9e47e361"
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
